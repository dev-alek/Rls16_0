using ibs.th.str.ptrl.*.
using ibs.th.gbl.ptrl.par.*.
using ibs.th.str.utd.handlers.introduce.
define input        parameter parparentproc   as   handle                  no-undo.
define input-output parameter pardoc-rec      as   recid                   no-undo.
define input        parameter pardoc-mode     as   character               no-undo.
define input        parameter partype         as   character               no-undo.
define input        parameter parinternal     as   logical                 no-undo.
define input-output parameter parnext-prev    as   logical                 no-undo.
define input        parameter parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define input        parameter paris-holding   as   logical                 no-undo.
define input-output parameter line-rec        as   recid                   no-undo.
define input        parameter br-handle       as   handle                  no-undo.
define input        parameter bf-handle       as   handle                  no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Документ инвентаризации":U .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-parts no-undo   like ub.parts   field free-qnty as decimal   field free-cli-qnty as decimal .
procedure partslib-clear-temp-parts :
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error
  :
    for each buf_temp-parts
    on error undo, return error
    :
      delete buf_temp-parts .
    end.
  end.
end procedure.
procedure partslib-create-temp-parts :
  define parameter buffer buf_parts       for ub.parts .
  define parameter buffer buf_temp-parts  for temp-parts .
  define input  parameter p-goods-twounit as logical   no-undo .
  define variable v-base-part-code as character no-undo .
  do
  on error undo, return error
  :
    if p-goods-twounit = true
    then do:
      assign
        v-base-part-code = entry(1, buf_parts.part-code, '#':U)
      .
    end.
    else do:
      assign
        v-base-part-code = buf_parts.part-code
      .
    end.
    find first buf_temp-parts exclusive-lock
      where buf_temp-parts.obj-type  = buf_parts.obj-type
        and buf_temp-parts.obj-code  = buf_parts.obj-code
        and buf_temp-parts.artic     = buf_parts.artic
        and buf_temp-parts.prod-type = buf_parts.prod-type
        and buf_temp-parts.prod-code = buf_parts.prod-code
        and buf_temp-parts.in-code   = buf_parts.in-code
        and buf_temp-parts.out-code  = 'free-zone':U
        and buf_temp-parts.part-code = v-base-part-code
      no-error.
    if not available buf_temp-parts
    then do:
      create buf_temp-parts .
      buffer-copy buf_parts to buf_temp-parts
      assign
        buf_temp-parts.out-code  = 'free-zone':U
        buf_temp-parts.part-code = v-base-part-code
        buf_temp-parts.rsrv-free = yes
        buf_temp-parts.status_   = no
        buf_temp-parts.qnty      = 0
        buf_temp-parts.fact-qnty = 0
        buf_temp-parts.real-qnty = 0
        buf_temp-parts.cli-qnty  = 0
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info3 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run partslib-clear-temp-parts in this-procedure .
    for each buf_parts
      where buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
        and buf_parts.rsrv-free = yes
        and buf_parts.status_   = no
        and buf_parts.in-code   <> buf_parts.out-code
    on error undo, return error
    :
      run partslib-create-temp-parts in this-procedure
        (buffer buf_parts
        ,buffer buf_temp-parts
        ,input  v-goods-twounit
        ) .
      define variable v-parts-qnty          as decimal   no-undo .
      define variable v-parts-cli-qnty      as decimal   no-undo .
      define variable v-parts-free-qnty     as decimal   no-undo .
      define variable v-parts-free-cli-qnty as decimal   no-undo .
      if buf_parts.out-code = 'free-zone':U
      then do:
        assign
          v-parts-qnty          = buf_parts.qnty
          v-parts-cli-qnty      = buf_parts.cli-qnty
          v-parts-free-qnty     = buf_parts.qnty
          v-parts-free-cli-qnty = buf_parts.cli-qnty
        .
      end.
      else do:
        assign
          v-parts-qnty          = abs(buf_parts.qnty)
          v-parts-cli-qnty      = abs(buf_parts.cli-qnty)
          v-parts-free-qnty     = 0
          v-parts-free-cli-qnty = 0
        .
      end.
      assign
        buf_temp-parts.qnty          = buf_temp-parts.qnty          + v-parts-qnty
        buf_temp-parts.fact-qnty     = buf_temp-parts.fact-qnty     + v-parts-qnty
        buf_temp-parts.real-qnty     = 0
        buf_temp-parts.cli-qnty      = buf_temp-parts.cli-qnty      + v-parts-cli-qnty
        buf_temp-parts.free-qnty     = buf_temp-parts.free-qnty     + v-parts-free-qnty
        buf_temp-parts.free-cli-qnty = buf_temp-parts.free-cli-qnty + v-parts-free-cli-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  do
  on error undo, return error
  :
    do transaction
    on error undo, return error
    :
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info3 skip
          "Невозможно найти товар на объекте" skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    run partslib-init-temp-parts in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info3 skip
        "Ошибка при инициализации текущего остатка по партиям свободной зоны" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-include-fact-order = true
    then do:
      assign
        p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    define variable v-max-fact-order as character no-undo .
    run factord-max-fact-order in this-procedure
      (output v-max-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info3 skip
        "Ошибка при вызове процедуры factord-max-fact-order" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-update-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input p-fact-order
      ,input v-max-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info3 skip
        "Ошибка при вызове процедуры partslib-update-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        "v-max-fact-order" v-max-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-update-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-start-fact-order   as decimal   no-undo .
  define input parameter p-end-fact-order     as decimal   no-undo .
  define input parameter p-lock-gds-obj       as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  define buffer buf_doc-line for ub.doc-line .
  define variable v-total-parts-qnty as decimal   no-undo .
  define variable v-goods-gds-goods  as logical   no-undo .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
    if p-start-fact-order > p-end-fact-order
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info3 skip
        "Ошибка задания входных параметров" skip
        "Начало интервала превышает конец интервала" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-start-fact-order" p-start-fact-order skip
        "p-end-fact-order"   p-end-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-lock-gds-obj = true
    then do:
      do transaction
      on error undo, return error
      :
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info3 skip
            "Невозможно найти gds-obj" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        find current buf_gds-obj exclusive-lock .
      end.
    end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'gds-goods=request':u
  ,output v-goods-gds-goods
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info3 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "gds-goods=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info3 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order > p-start-fact-order
        and buf_doc-line.fact-order <= p-end-fact-order
    on error undo, return error
    :
      run partslib-process-document in this-procedure
        (input  buf_doc-line.doc-code
        ,input  p-obj-type
        ,input  p-obj-code
        ,input  p-artic
        ,input  p-prod-type
        ,input  p-prod-code
        ,input  v-goods-gds-goods
        ,input  v-goods-twounit
        ,output v-total-parts-qnty
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info3 skip
          "Ошибка при вызове процедуры partslib-process-document" skip
          "Документ" buf_doc-line.doc-code skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "p-start-fact-order" p-start-fact-order skip
          "p-end-fact-order" p-end-fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure partslib-process-document :
  define input  parameter p-doc-code         as character no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-artic            as character no-undo .
  define input  parameter p-prod-type        as character no-undo .
  define input  parameter p-prod-code        as integer   no-undo .
  define input  parameter p-goods-gds-goods  as logical   no-undo .
  define input  parameter p-goods-twounit    as logical   no-undo .
  define output parameter p-total-parts-qnty as decimal   no-undo .
  define variable v-parts-sign as integer   no-undo .
  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer buf_doc-line   for ub.doc-line .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      undo, return error substitute("Ошибка при поиске документа. Документ &1"
                                   ,p-doc-code
                                   ) .
    end.
    case buf_trn-doc.doc-type
    :
      when 'при':U or
      when 'возврат':U or
      when 'инв':U
      then do:
        assign
          v-parts-sign = -1
        .
      end.
      when 'рас':U or
      when 'спи':U
      then do:
        assign
          v-parts-sign = 1
        .
      end.
      otherwise do:
        undo, return error substitute("Неизвестный тип документа &1"
                                    ,buf_trn-doc.doc-type
                                    ) .
      end.
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      undo, return error substitute("Ошибка при поиске строки документа. Документ &1. Артикул &2 &3 &4"
                                   ,p-doc-code
                                   ,artic
                                   ,prod-type
                                   ,prod-code
                                   ) .
    end.
    assign
      p-total-parts-qnty = 0
    .
    if p-goods-gds-goods = true
    then do:
      for each buf_parts no-lock
        where buf_parts.out-code  = p-doc-code
          and buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
      on error undo, return error
      :
        run partslib-create-temp-parts in this-procedure
          (buffer buf_parts
          ,buffer buf_temp-parts
          ,input  p-goods-twounit
          ) .
        assign
          p-total-parts-qnty        = p-total-parts-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.qnty       = buf_temp-parts.qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.fact-qnty  = buf_temp-parts.fact-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.cli-qnty   = buf_temp-parts.cli-qnty
                                    + v-parts-sign * buf_parts.cli-qnty
        .
        if buf_temp-parts.qnty = 0
        then do:
          delete buf_temp-parts .
        end.
      end.
    end.
    else do:
      assign
        p-total-parts-qnty = p-total-parts-qnty
                           + v-parts-sign * buf_doc-line.fact-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-date :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define input parameter p-fact-date       as date      no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-date: определение партий свободной зоны на любую дату".
  do
  on error undo, return error
  :
    define variable v-fact-order                as decimal   no-undo .
    define variable v-shift-end-fact-order      as decimal   no-undo .
    define variable v-day-end-fact-order        as decimal   no-undo .
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  ?
      ,input  0
      ,input  false
      ,output v-fact-order
      ,output v-shift-end-fact-order
      ,output v-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info3 skip
        "Ошибка при определении момента времени, на который требуется остаток" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-init-temp-parts-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input v-day-end-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info3 skip
        "Ошибка при вызове метода partslib-init-temp-parts-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-calc-cost :
  define output parameter p-fact-qnty      as decimal   no-undo .
  define output parameter p-vat-pc         as decimal   no-undo .
  define output parameter p-slt-pc         as decimal   no-undo .
  define output parameter p-sum-base       as decimal   no-undo .
  define output parameter p-sum-rubl       as decimal   no-undo .
  define output parameter p-vat-base       as decimal   no-undo .
  define output parameter p-vat-rubl       as decimal   no-undo .
  define output parameter p-slt-base       as decimal   no-undo .
  define output parameter p-slt-rubl       as decimal   no-undo .
  define output parameter p-road-tax-base  as decimal   no-undo .
  define output parameter p-road-tax-rubl  as decimal   no-undo .
  define output parameter p-transport-base as decimal   no-undo .
  define output parameter p-transport-rubl as decimal   no-undo .
  define output parameter p-other-base     as decimal   no-undo .
  define output parameter p-other-rubl     as decimal   no-undo .
  define output parameter p-excise-base    as decimal   no-undo .
  define output parameter p-excise-rubl    as decimal   no-undo .
  define variable vss-description as character no-undo init "partslib-calc-cost: расчет сумм в учетных ценах".
  do
  on error undo, return error return-value
  :
    define buffer buf_temp-parts for temp-parts .
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
    for each buf_temp-parts
    on error undo, return error
    :
assign
  price-rubl-with-tax-loc = buf_temp-parts.price-rubl
  price-base-with-tax-loc = buf_temp-parts.price-base
.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_temp-parts.out-code = 'free-zone':U     or
     buf_temp-parts.out-code = 'out-zone':U   or
     buf_temp-parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_temp-parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = buf_temp-parts.price-cli
   cli-base-rate          = buf_temp-parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_temp-parts.road-tax-base  = ? then 0 else buf_temp-parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_temp-parts.road-tax-rubl  = ? then 0 else buf_temp-parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_temp-parts.transport-base = ? then 0 else buf_temp-parts.transport-base)
          transport-rubl-loc = (if buf_temp-parts.transport-rubl = ? then 0 else buf_temp-parts.transport-rubl)
          other-base-loc     = (if buf_temp-parts.other-base     = ? then 0 else buf_temp-parts.other-base)
          other-rubl-loc     = (if buf_temp-parts.other-rubl     = ? then 0 else buf_temp-parts.other-rubl)
          vat-pc-loc         = (if buf_temp-parts.vat-pc         = ? then 0 else buf_temp-parts.vat-pc)
          slt-pc-loc         = (if buf_temp-parts.slt-pc         = ? then 0 else buf_temp-parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_temp-parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_temp-parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_temp-parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_temp-parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
      assign
        p-fact-qnty      = p-fact-qnty      + buf_temp-parts.fact-qnty
        p-vat-pc         = p-vat-pc         + vat-pc-loc
        p-slt-pc         = p-slt-pc         + slt-pc-loc
        p-sum-base       = p-sum-base       + price-base-with-tax-loc * buf_temp-parts.fact-qnty
        p-sum-rubl       = p-sum-rubl       + price-rubl-with-tax-loc * buf_temp-parts.fact-qnty
        p-vat-base       = p-vat-base       + vat-base-loc            * buf_temp-parts.fact-qnty
        p-vat-rubl       = p-vat-rubl       + vat-rubl-loc            * buf_temp-parts.fact-qnty
        p-slt-base       = p-slt-base       + slt-base-loc            * buf_temp-parts.fact-qnty
        p-slt-rubl       = p-slt-rubl       + slt-rubl-loc            * buf_temp-parts.fact-qnty
        p-road-tax-base  = p-road-tax-base  + road-tax-base-loc       * buf_temp-parts.fact-qnty
        p-road-tax-rubl  = p-road-tax-rubl  + road-tax-rubl-loc       * buf_temp-parts.fact-qnty
        p-transport-base = p-transport-base + transport-base-loc      * buf_temp-parts.fact-qnty
        p-transport-rubl = p-transport-rubl + transport-rubl-loc      * buf_temp-parts.fact-qnty
        p-other-base     = p-other-base     + other-base-loc          * buf_temp-parts.fact-qnty
        p-other-rubl     = p-other-rubl     + other-rubl-loc          * buf_temp-parts.fact-qnty
        p-excise-base    = p-excise-base    + 0
        p-excise-rubl    = p-excise-rubl    + 0
      .
    end.
    if p-fact-qnty      = ?
    or p-sum-base       = ?
    or p-sum-rubl       = ?
    or p-vat-base       = ?
    or p-vat-rubl       = ?
    or p-slt-base       = ?
    or p-slt-rubl       = ?
    or p-road-tax-base  = ?
    or p-road-tax-rubl  = ?
    or p-transport-base = ?
    or p-transport-rubl = ?
    or p-other-base     = ?
    or p-other-rubl     = ?
    or p-excise-base    = ?
    or p-excise-rubl    = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info3 skip
        "Программа in-vatp.i вернула неопределенные значения" skip
        "p-fact-qnty"      p-fact-qnty      skip
        "p-sum-base"       p-sum-base       skip
        "p-sum-rubl"       p-sum-rubl       skip
        "p-vat-base"       p-vat-base       skip
        "p-vat-rubl"       p-vat-rubl       skip
        "p-slt-base"       p-slt-base       skip
        "p-slt-rubl"       p-slt-rubl       skip
        "p-road-tax-base"  p-road-tax-base  skip
        "p-road-tax-rubl"  p-road-tax-rubl  skip
        "p-transport-base" p-transport-base skip
        "p-transport-rubl" p-transport-rubl skip
        "p-other-base"     p-other-base     skip
        "p-other-rubl"     p-other-rubl     skip
        "p-excise-base"    p-excise-base    skip
        "p-excise-rubl"    p-excise-rubl    skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
define new global shared variable g#libbcrcn as handle no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure doc-code:
define input  parameter parmode          as   character           no-undo.
define input  parameter parobj-type      like ub.clients.obj-type no-undo.
define input  parameter parobj-code      like ub.clients.obj-code no-undo.
define input  parameter parroot-doc-code like ub.trn-doc.doc-code no-undo.
define output parameter pardoc-code      like ub.trn-doc.doc-code no-undo.
define buffer buf_sys-ctrl for ub.sys-ctrl  .
define variable vardb-remote     as   logical             no-undo.
define variable vartemp-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-delimiter as character no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
find first buf_sys-ctrl no-lock .
vardb-remote = buf_sys-ctrl.db-num <> 0 .
  CASE parmode:
    when "main":u then do:
      if vardb-remote then do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (parobj-code, ">>>>9")) + substring (parobj-type, (if g#language = "RUS" then 1 else 2), 1).
      end.
      else do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-".
      end.
    end.
    when "trio" then do:
      assign
        pardoc-code = replace (parroot-doc-code, "=", "*").
    end.
    otherwise do:
      assign
      v-delimiter = entry(lookup(entry(1, parmode), "main,chip,pair,flora,trio-m,quadro,stock-up,stock-down,stock-fix," +                          "main_s,chip_s,pair_s,trio-m_s,quadro_s,stock-up_s,stock-down_s,stock-fix_s":U), ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)))
      no-error
      .
      if error-status:error  then do:
        undo, return error substitute("Ошибка при генерации номера документа&1Неверное значение параметра parmode &2"
                                      ,chr(10)
                                      ,parmode
                                      ).
      end.
      if num-entries(parmode) = 1
      and parmode <> "chip":U
      and parmode <> "chip_s":U
      then do:
        assign
        pardoc-code = replace (parroot-doc-code, "-", v-delimiter).
      end.
      else if (lookup("chip":U, parmode) > 0
               or
               lookup("chip_s":U, parmode) > 0) then do:
        assign
          vartemp-doc-code = parroot-doc-code.
        do while true:
          if index (vartemp-doc-code , ".") = 0 then
            vartemp-doc-code  = replace (vartemp-doc-code , v-delimiter, v-delimiter + "1.").
          else
            vartemp-doc-code  =
            substring (vartemp-doc-code , 1, index (vartemp-doc-code, v-delimiter)) +
            string (integer (substring (vartemp-doc-code, index (vartemp-doc-code, v-delimiter) + 1, index (vartemp-doc-code, ".") - index (vartemp-doc-code, v-delimiter) - 1)) + 1) +
            substring (vartemp-doc-code, index (vartemp-doc-code, ".")).
          if not can-find (ub.trn-doc where ub.trn-doc.doc-code = vartemp-doc-code no-lock) then leave.
        end.
        assign
          pardoc-code = vartemp-doc-code.
      end.
    end.
  end CASE.
  if pardoc-code = '':U
  or (parroot-doc-code <> '':U
  and pardoc-code = parroot-doc-code) then do:
    undo, return error substitute("Ошибка при генерации номера документа&1"
                                  ,chr(10)).
  end.
end.
end. // procedure/method
function get-doc-code-int64 returns int64
  ( input p-doc-code as character ) :
  define variable v-ind              as integer   no-undo .
  define variable v-num-entries      as integer   no-undo .
  define variable v-doc-code-int64   as int64     no-undo .
  define variable v-canonic-doc-code as character no-undo .
  assign
    v-num-entries      = num-entries( ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) )
    v-canonic-doc-code = p-doc-code
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-canonic-doc-code = entry(1, v-canonic-doc-code, entry( v-ind, ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) ) )
    .
  end.
  assign
    v-doc-code-int64 = int64(v-canonic-doc-code) no-error
  .
  return v-doc-code-int64 .
end. // function/method
def var vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-allsum-line      no-undo
field sum-type           as   character
field fact-qnty          like ub.doc-line.fact-qnty
field cli-qnty           like ub.doc-line.cli-qnty
field sum-dsc-base-doc   like ub.doc-line.price-base
field sum-dsc-rubl-doc   like ub.doc-line.price-base
field dsc-base-doc       like ub.doc-line.price-base
field dsc-rubl-doc       like ub.doc-line.price-base
field vat-base-doc       like ub.doc-line.price-base
field vat-rubl-doc       like ub.doc-line.price-base
field vat-base-buyer-doc like ub.doc-line.price-base
field vat-rubl-buyer-doc like ub.doc-line.price-base
field slt-base-doc       like ub.doc-line.price-base
field slt-rubl-doc       like ub.doc-line.price-base
field road-tax-base-doc  like ub.doc-line.price-base
field road-tax-rubl-doc  like ub.doc-line.price-base
field excise-base-doc    like ub.doc-line.price-base
field excise-rubl-doc    like ub.doc-line.price-base
field sum-dsc-base-acc   like ub.doc-line.price-base
field sum-dsc-rubl-acc   like ub.doc-line.price-base
field sum-dsc-cli-acc    like ub.doc-line.price-cli
field dsc-base-acc       like ub.doc-line.price-base
field dsc-rubl-acc       like ub.doc-line.price-base
field dsc-cli-acc        like ub.doc-line.price-cli
field vat-base-acc       like ub.doc-line.price-base
field vat-rubl-acc       like ub.doc-line.price-base
field vat-cli-acc        like ub.doc-line.price-cli
field slt-base-acc       like ub.doc-line.price-base
field slt-rubl-acc       like ub.doc-line.price-base
field slt-cli-acc        like ub.doc-line.price-cli
field road-tax-base-acc  like ub.doc-line.price-base
field road-tax-rubl-acc  like ub.doc-line.price-base
field road-tax-cli-acc   like ub.doc-line.price-cli
field excise-base-acc    like ub.doc-line.price-base
field excise-rubl-acc    like ub.doc-line.price-base
field excise-cli-acc     like ub.doc-line.price-cli
field transport-base-acc like ub.doc-line.price-base
field transport-rubl-acc like ub.doc-line.price-base
field transport-cli-acc  like ub.doc-line.price-cli
field other-base-acc     like ub.doc-line.price-base
field other-rubl-acc     like ub.doc-line.price-base
field other-cli-acc      like ub.doc-line.price-cli
field sum-dsc-base-cur   like ub.doc-line.price-base
field sum-dsc-rubl-cur   like ub.doc-line.price-base
field dsc-base-cur       like ub.doc-line.price-base
field dsc-rubl-cur       like ub.doc-line.price-base
field vat-base-cur       like ub.doc-line.price-base
field vat-rubl-cur       like ub.doc-line.price-base
field vat-base-buyer-cur like ub.doc-line.price-base
field vat-rubl-buyer-cur like ub.doc-line.price-base
field slt-base-cur       like ub.doc-line.price-base
field slt-rubl-cur       like ub.doc-line.price-base
field road-tax-base-cur  like ub.doc-line.price-base
field road-tax-rubl-cur  like ub.doc-line.price-base
field excise-base-cur    like ub.doc-line.price-base
field excise-rubl-cur    like ub.doc-line.price-base
index sum-type is primary unique sum-type.
.
define temp-table tt-allsum no-undo
field sum-type           as   character
field fact-qnty             as decimal
field cli-qnty              as decimal
field sum-dsc-base-doc      as decimal
field sum-dsc-rubl-doc      as decimal
field dsc-base-doc          as decimal
field dsc-rubl-doc          as decimal
field vat-base-doc          as decimal
field vat-rubl-doc          as decimal
field vat-base-buyer-doc    as decimal
field vat-rubl-buyer-doc    as decimal
field slt-base-doc          as decimal
field slt-rubl-doc          as decimal
field road-tax-base-doc     as decimal
field road-tax-rubl-doc     as decimal
field excise-base-doc       as decimal
field excise-rubl-doc       as decimal
field sum-dsc-base-acc      as decimal
field sum-dsc-rubl-acc      as decimal
field sum-dsc-cli-acc       as decimal
field dsc-base-acc          as decimal
field dsc-rubl-acc          as decimal
field dsc-cli-acc           as decimal
field vat-base-acc          as decimal
field vat-rubl-acc          as decimal
field vat-cli-acc           as decimal
field slt-base-acc          as decimal
field slt-rubl-acc          as decimal
field slt-cli-acc           as decimal
field road-tax-base-acc     as decimal
field road-tax-rubl-acc     as decimal
field road-tax-cli-acc      as decimal
field excise-base-acc       as decimal
field excise-rubl-acc       as decimal
field excise-cli-acc        as decimal
field transport-base-acc    as decimal
field transport-rubl-acc    as decimal
field transport-cli-acc     as decimal
field other-base-acc        as decimal
field other-rubl-acc        as decimal
field other-cli-acc         as decimal
field sum-dsc-base-cur      as decimal
field sum-dsc-rubl-cur      as decimal
field dsc-base-cur          as decimal
field dsc-rubl-cur          as decimal
field vat-base-cur          as decimal
field vat-rubl-cur          as decimal
field vat-base-buyer-cur    as decimal
field vat-rubl-buyer-cur    as decimal
field slt-base-cur          as decimal
field slt-rubl-cur          as decimal
field road-tax-base-cur     as decimal
field road-tax-rubl-cur     as decimal
field excise-base-cur       as decimal
field excise-rubl-cur       as decimal
index sum-type is primary unique sum-type.
define temp-table tt-clcparts no-undo like ub.parts
field part-cur-base like ub.gds-dtl.price-base
field part-cur-road-tax like ub.gds-dtl.price-base
field part-cur-excise like ub.gds-dtl.price-base
.
define variable v-calcbypart as log no-undo.
procedure clcprtsl_calc-parts :
define input parameter parrec-parts        as   recid                   no-undo.
define input parameter paris-doc           as   logical                 no-undo.
define input parameter paris-cur           as   logical                 no-undo.
define input parameter parroad-tax         like ub.doc-line.road-tax    no-undo.
define input parameter parexcise           like ub.doc-line.excise      no-undo.
define input parameter parvat-pc           like ub.doc-line.vat-pc      no-undo.
define input parameter parcons-vat-pc      like ub.doc-line.cons-vat-pc no-undo.
define input parameter parslt-pc           like ub.doc-line.slt-pc      no-undo.
define input parameter parbase-rate        like ub.trn-doc.base-rate    no-undo.
define input parameter parbase-scale       like ub.trn-doc.base-scale   no-undo.
define input parameter parr-b              as   character               no-undo.
define input parameter parcur-base         like ub.gds-dtl.cur-base     no-undo.
define input parameter parcurroad-tax      like ub.doc-line.road-tax    no-undo.
define input parameter parcurexcise        like ub.doc-line.excise      no-undo.
define input parameter parcurvat-pc        like ub.doc-line.vat-pc      no-undo.
define input parameter parcurcons-vat-pc   like ub.doc-line.cons-vat-pc no-undo.
define input parameter parcurslt-pc        like ub.doc-line.slt-pc      no-undo.
define variable parartic        like ub.parts.artic         no-undo.
define variable parprod-type    like ub.parts.prod-type     no-undo.
define variable parprod-code    like ub.parts.prod-code     no-undo.
define variable pardoc-type     like ub.parts.doc-type      no-undo.
define variable pardoc-code     like ub.parts.out-code      no-undo.
define variable parobj-type     like ub.parts.obj-type      no-undo.
define variable parobj-code     like ub.parts.obj-code      no-undo.
define variable parprice-base   like ub.gds-dtl.price-base  no-undo.
define variable parprice-rubl   like ub.gds-dtl.price-rubl  no-undo.
define variable pardiscnt-base  like ub.gds-dtl.discnt-base no-undo.
define variable pardiscnt-rubl  like ub.gds-dtl.discnt-rubl no-undo.
define variable parfact-qnty    like ub.parts.fact-qnty     no-undo.
define variable parcli-qnty     like ub.parts.cli-qnty      no-undo.
define variable pardoc-qnty     like ub.parts.qnty          no-undo.
define variable parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define variable parcurartic        like ub.parts.artic         no-undo.
define variable parcurprod-type    like ub.parts.prod-type     no-undo.
define variable parcurprod-code    like ub.parts.prod-code     no-undo.
define variable parcurdoc-type     like ub.parts.doc-type      no-undo.
define variable parcurdoc-code     like ub.parts.out-code      no-undo.
define variable parcurobj-type     like ub.parts.obj-type      no-undo.
define variable parcurobj-code     like ub.parts.obj-code      no-undo.
define variable parcurprice-base   like ub.gds-dtl.price-base  no-undo.
define variable parcurprice-rubl   like ub.gds-dtl.price-rubl  no-undo.
define variable parcurdiscnt-base  like ub.gds-dtl.discnt-base no-undo.
define variable parcurdiscnt-rubl  like ub.gds-dtl.discnt-rubl no-undo.
define variable parcurfact-qnty    like ub.parts.fact-qnty     no-undo.
define variable parcurcli-qnty     like ub.parts.cli-qnty      no-undo.
define variable parcurdoc-qnty     like ub.parts.qnty          no-undo.
define variable parcurbase-rate    like ub.trn-doc.base-rate   no-undo.
define variable parcurbase-scale   like ub.trn-doc.base-scale  no-undo.
define variable parcurext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define buffer bf_tt-allsum     for tt-allsum.
define buffer bfs_tt-allsum    for tt-allsum.
define buffer bfpc_tt-allsum   for tt-allsum.
define buffer bfspc_tt-allsum  for tt-allsum.
define buffer bfacc_tt-allsum  for tt-allsum.
define buffer bfsacc_tt-allsum for tt-allsum.
define buffer cl_tt-clcparts   for tt-clcparts.
define buffer bf_trn-doc       for ub.trn-doc.
define buffer bf_sysconf       for ub.sysconf.
    define buffer   in-vatp-trn-doccl  for ub.trn-doc .
    define buffer   in-vatp-partscl    for ub.parts   .
    define buffer   in-vatp-doccl      for ub.trn-doc .
    define buffer   in-vatp-goodscl    for ub.goods   .
    define buffer   in-vatp-sysconfcl  for ub.sysconf .
    define buffer   in-vatp_doc-attrcl for ub.doc-attr.
    define variable in-vatp-have-vat-sltcl       as   logical initial yes    no-undo.
    define variable vat-pc-loccl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbcl                  as   character              no-undo.
    define variable slt-pc-loccl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-ratecl              as   decimal                no-undo.
    define variable price-rubl-with-tax-loccl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loccl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loccl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loccl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loccl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loccl  like ub.doc-line.price-base no-undo.
    define variable vat-base-loccl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loccl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loccl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loccl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loccl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loccl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loccl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loccl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loccl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loccl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loccl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loccl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loccl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loccl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loccl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loccl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdcl             as   character              no-undo.
    define variable varinvatp-typecl             as   character              no-undo.
    define  variable price-rubl-with-tax-salecl    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-salecl    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-salecl like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-salecl like ub.doc-line.price-base no-undo.
    define  variable vat-base-salecl               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-salecl               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyercl              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyercl              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-salecl               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-salecl               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-salecl          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-salecl          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-salecl            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-salecl            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-salecl            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-salecl            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlcl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlcl for ub.gds-dtl.
    define buffer out-vatp_partscl       for ub.parts.
    define buffer out-vatp_sysconfcl     for ub.sysconf.
    define buffer out-vatp_doc-linecl    for ub.doc-line.
    define buffer out-vatp_goodscl       for ub.goods.
    define buffer out-vatp_trn-doccl     for ub.trn-doc.
    define buffer out-vatp_doc-attrcl    for ub.doc-attr.
    define variable varprice-base-conscl      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-conscl      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typecl         as   character                           no-undo.
    define variable varfrm-cnsvcl              as   character                           no-undo.
    define variable varroot-nodecl             as   integer                             no-undo.
    define variable varempty-scalecl           as   logical                             no-undo.
    define variable varis-cons-parts-havecl    as   logical                             no-undo.
    define variable varsum-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpcl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpcl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpcl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpcl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntycl             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntycl             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlcl        as   logical                             no-undo.
    define variable varcurclprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurclprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurcldiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcldiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbcl               as   character                           no-undo.
    define variable out-vatp-have-vat-sltcl    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-dococl  for ub.trn-doc .
    define buffer   in-vatp-partsocl    for ub.parts   .
    define buffer   in-vatp-dococl      for ub.trn-doc .
    define buffer   in-vatp-goodsocl    for ub.goods   .
    define buffer   in-vatp-sysconfocl  for ub.sysconf .
    define buffer   in-vatp_doc-attrocl for ub.doc-attr.
    define variable in-vatp-have-vat-sltocl       as   logical initial yes    no-undo.
    define variable vat-pc-lococl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbocl                  as   character              no-undo.
    define variable slt-pc-lococl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateocl              as   decimal                no-undo.
    define variable price-rubl-with-tax-lococl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-lococl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-lococl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-lococl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-lococl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-lococl  like ub.doc-line.price-base no-undo.
    define variable vat-base-lococl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-lococl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-lococl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-lococl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-lococl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-lococl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-lococl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-lococl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-lococl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-lococl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-lococl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-lococl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-lococl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-lococl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-lococl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-lococl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdocl             as   character              no-undo.
    define variable varinvatp-typeocl             as   character              no-undo.
    define  variable price-rubl-with-tax-salecur    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-salecur    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-salecur like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-salecur like ub.doc-line.price-base no-undo.
    define  variable vat-base-salecur               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-salecur               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyercur              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyercur              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-salecur               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-salecur               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-salecur          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-salecur          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-salecur            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-salecur            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-salecur            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-salecur            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlcur     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlcur for ub.gds-dtl.
    define buffer out-vatp_partscur       for ub.parts.
    define buffer out-vatp_sysconfcur     for ub.sysconf.
    define buffer out-vatp_doc-linecur    for ub.doc-line.
    define buffer out-vatp_goodscur       for ub.goods.
    define buffer out-vatp_trn-doccur     for ub.trn-doc.
    define buffer out-vatp_doc-attrcur    for ub.doc-attr.
    define variable varprice-base-conscur      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-conscur      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typecur         as   character                           no-undo.
    define variable varfrm-cnsvcur              as   character                           no-undo.
    define variable varroot-nodecur             as   integer                             no-undo.
    define variable varempty-scalecur           as   logical                             no-undo.
    define variable varis-cons-parts-havecur    as   logical                             no-undo.
    define variable varsum-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpcur  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpcur   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpcur  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpcur   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntycur             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntycur             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlcur        as   logical                             no-undo.
    define variable varcurcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbcur               as   character                           no-undo.
    define variable out-vatp-have-vat-sltcur    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-dococur  for ub.trn-doc .
    define buffer   in-vatp-partsocur    for ub.parts   .
    define buffer   in-vatp-dococur      for ub.trn-doc .
    define buffer   in-vatp-goodsocur    for ub.goods   .
    define buffer   in-vatp-sysconfocur  for ub.sysconf .
    define buffer   in-vatp_doc-attrocur for ub.doc-attr.
    define variable in-vatp-have-vat-sltocur       as   logical initial yes    no-undo.
    define variable vat-pc-lococur                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbocur                  as   character              no-undo.
    define variable slt-pc-lococur                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateocur              as   decimal                no-undo.
    define variable price-rubl-with-tax-lococur    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-lococur    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-lococur     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-lococur like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-lococur like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-lococur  like ub.doc-line.price-base no-undo.
    define variable vat-base-lococur               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-lococur               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-lococur                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-lococur               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-lococur               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-lococur                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-lococur          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-lococur          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-lococur           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-lococur         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-lococur         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-lococur          like ub.doc-line.price-rubl no-undo.
    define variable other-base-lococur             like ub.doc-line.price-base no-undo.
    define variable other-rubl-lococur             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-lococur              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-lococur          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdocur             as   character              no-undo.
    define variable varinvatp-typeocur             as   character              no-undo.
do on error undo, return error return-value :
find first cl_tt-clcparts where recid(cl_tt-clcparts) = parrec-parts no-lock.
for each bf_tt-allsum on error undo, return error return-value :
  delete bf_tt-allsum.
end.
assign
  price-rubl-with-tax-loccl = cl_tt-clcparts.price-rubl
  price-base-with-tax-loccl = cl_tt-clcparts.price-base
.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbcl
  )  .
  if cl_tt-clcparts.out-code = 'free-zone':U     or
     cl_tt-clcparts.out-code = 'out-zone':U   or
     cl_tt-clcparts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltcl = yes.
  end.
  else do:
    find first in-vatp_doc-attrcl no-lock
      where in-vatp_doc-attrcl.doc-code  = cl_tt-clcparts.out-code
        and in-vatp_doc-attrcl.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrcl then do:
      assign
        in-vatp-have-vat-sltcl = yes.
    end.
    else do:
         in-vatp-have-vat-sltcl = no.
    end.
  end.
  assign
   price-cli-with-tax-loccl = cl_tt-clcparts.price-cli
   cli-base-ratecl          = cl_tt-clcparts.cli-base-rate.
  ASSIGN   road-tax-base-loccl  = (if cl_tt-clcparts.road-tax-base  = ? then 0 else cl_tt-clcparts.road-tax-base)
           road-tax-rubl-loccl  = (if cl_tt-clcparts.road-tax-rubl  = ? then 0 else cl_tt-clcparts.road-tax-rubl).
  ASSIGN  transport-base-loccl = (if cl_tt-clcparts.transport-base = ? then 0 else cl_tt-clcparts.transport-base)
          transport-rubl-loccl = (if cl_tt-clcparts.transport-rubl = ? then 0 else cl_tt-clcparts.transport-rubl)
          other-base-loccl     = (if cl_tt-clcparts.other-base     = ? then 0 else cl_tt-clcparts.other-base)
          other-rubl-loccl     = (if cl_tt-clcparts.other-rubl     = ? then 0 else cl_tt-clcparts.other-rubl)
          vat-pc-loccl         = (if cl_tt-clcparts.vat-pc         = ? then 0 else cl_tt-clcparts.vat-pc)
          slt-pc-loccl         = (if cl_tt-clcparts.slt-pc         = ? then 0 else cl_tt-clcparts.slt-pc).
          ASSIGN   slt-base-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-base-with-tax-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl)))                           * slt-pc-loccl / (100 + slt-pc-loccl))                        vat-base-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-base-with-tax-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl))) * (1 - slt-pc-loccl / (100 + slt-pc-loccl)) * vat-pc-loccl / (100 + vat-pc-loccl)).
    ASSIGN   slt-rubl-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-rubl-with-tax-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl)))                           * slt-pc-loccl / (100 + slt-pc-loccl))                        vat-rubl-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-rubl-with-tax-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl))) * (1 - slt-pc-loccl / (100 + slt-pc-loccl)) * vat-pc-loccl / (100 + vat-pc-loccl)).
  assign
    exch-rate-cli-loccl = (cl_tt-clcparts.price-rubl - transport-rubl-loccl - other-rubl-loccl - road-tax-rubl-loccl - (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-rubl-loccl else 0) - (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-rubl-loccl else 0)) / cl_tt-clcparts.price-cli .
  assign
    slt-cli-loccl        = slt-rubl-loccl       / exch-rate-cli-loccl
    vat-cli-loccl        = vat-rubl-loccl       / exch-rate-cli-loccl
    road-tax-cli-loccl   = road-tax-rubl-loccl  / exch-rate-cli-loccl
    transport-cli-loccl  = 0
    other-cli-loccl      = 0
  .
ASSIGN
          price-base-without-tax-loccl = price-base-with-tax-loccl - vat-base-loccl - slt-base-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl))
    price-rubl-without-tax-loccl = price-rubl-with-tax-loccl - vat-rubl-loccl - slt-rubl-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl))
.
if paris-doc then do:
  assign
    parartic     = cl_tt-clcparts.artic
    parprod-type = cl_tt-clcparts.prod-type
    parprod-code = cl_tt-clcparts.prod-code
    pardoc-type  = cl_tt-clcparts.doc-type
    pardoc-code  = cl_tt-clcparts.out-code
    parobj-type  = cl_tt-clcparts.obj-type
    parobj-code  = cl_tt-clcparts.obj-code.
if parext-doc-type = 'ot':U or
   parext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltcl = yes.
end.
else do:
  find first out-vatp_doc-attrcl no-lock
    where out-vatp_doc-attrcl.doc-code  = pardoc-code
      and out-vatp_doc-attrcl.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attrcl then do:
    assign
      out-vatp-have-vat-sltcl = yes.
  end.
  else do:
     out-vatp-have-vat-sltcl = no.
  end.
end.
find first out-vatp_goodscl where out-vatp_goodscl.artic     = parartic     and
                                   out-vatp_goodscl.prod-type = parprod-type and
                                   out-vatp_goodscl.prod-code = parprod-code no-lock.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  parartic
  ,input  parprod-type
  ,input  parprod-code
  ,output varroot-nodecl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" parartic parprod-type parprod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodecl
  ,input  'empty-scale=request'
  ,output varempty-scalecl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" parartic parprod-type parprod-code skip
    "Признак" varroot-nodecl skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbcl
  )  .
if varoutvprbcl = "base":u then do:
  assign
        road-tax-base-salecl    =  (if parroad-tax = ? then 0 else parroad-tax * 1)
    excise-base-salecl      =  (if parexcise   = ? then 0 else parexcise   * 1)
  .
end.
else do:
  assign
        road-tax-base-salecl    =  (if parroad-tax = ? then 0 else parroad-tax / parbase-rate * parbase-scale)
    excise-base-salecl      =  (if parexcise   = ? then 0 else parexcise   / parbase-rate * parbase-scale)
  .
end.
if varoutvprbcl = "rubl":u then do:
  assign
        road-tax-rubl-salecl    = (if parroad-tax = ? then 0 else parroad-tax * 1)
    excise-rubl-salecl      = (if parexcise   = ? then 0 else parexcise   * 1) .
end.
else do:
  assign
        road-tax-rubl-salecl    = (if parroad-tax = ? then 0 else parroad-tax * parbase-rate / parbase-scale)
    excise-rubl-salecl      = (if parexcise   = ? then 0 else parexcise   * parbase-rate / parbase-scale) .
end.
assign
  varis-cons-parts-havecl =  no.
assign
  varfact-qntycl       = 0
  varcons-qntycl       = 0
  varprice-base-conscl = 0
  varprice-rubl-conscl = 0.
find first out-vatp_doc-linecl where
           out-vatp_doc-linecl.doc-code   = pardoc-code
       and out-vatp_doc-linecl.artic      = parartic
       and out-vatp_doc-linecl.prod-type  = parprod-type
       and out-vatp_doc-linecl.prod-code  = parprod-code no-lock no-error.
if available out-vatp_doc-linecl           and
  (out-vatp_doc-linecl.status_ = 'запрос':U or out-vatp_goodscl.gds-type = 'у':U) then do:
  assign
    varfact-qntycl = out-vatp_doc-linecl.fact-qnty.
end.
else do:
  for each out-vatp_partscl where out-vatp_partscl.out-code   = pardoc-code
                               and out-vatp_partscl.obj-type   = parobj-type
                               and out-vatp_partscl.obj-code   = parobj-code
                               and out-vatp_partscl.artic      = parartic
                               and out-vatp_partscl.prod-type  = parprod-type
                               and out-vatp_partscl.prod-code  = parprod-code no-lock :
    if out-vatp_partscl.purch-code = 2 then do:
assign
  price-rubl-with-tax-lococl = out-vatp_partscl.price-rubl
  price-base-with-tax-lococl = out-vatp_partscl.price-base
.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbocl
  )  .
  if out-vatp_partscl.out-code = 'free-zone':U     or
     out-vatp_partscl.out-code = 'out-zone':U   or
     out-vatp_partscl.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltocl = yes.
  end.
  else do:
    find first in-vatp_doc-attrocl no-lock
      where in-vatp_doc-attrocl.doc-code  = out-vatp_partscl.out-code
        and in-vatp_doc-attrocl.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrocl then do:
      assign
        in-vatp-have-vat-sltocl = yes.
    end.
    else do:
         in-vatp-have-vat-sltocl = no.
    end.
  end.
  assign
   price-cli-with-tax-lococl = out-vatp_partscl.price-cli
   cli-base-rateocl          = out-vatp_partscl.cli-base-rate.
  ASSIGN   road-tax-base-lococl  = (if out-vatp_partscl.road-tax-base  = ? then 0 else out-vatp_partscl.road-tax-base)
           road-tax-rubl-lococl  = (if out-vatp_partscl.road-tax-rubl  = ? then 0 else out-vatp_partscl.road-tax-rubl).
  ASSIGN  transport-base-lococl = (if out-vatp_partscl.transport-base = ? then 0 else out-vatp_partscl.transport-base)
          transport-rubl-lococl = (if out-vatp_partscl.transport-rubl = ? then 0 else out-vatp_partscl.transport-rubl)
          other-base-lococl     = (if out-vatp_partscl.other-base     = ? then 0 else out-vatp_partscl.other-base)
          other-rubl-lococl     = (if out-vatp_partscl.other-rubl     = ? then 0 else out-vatp_partscl.other-rubl)
          vat-pc-lococl         = (if out-vatp_partscl.vat-pc         = ? then 0 else out-vatp_partscl.vat-pc)
          slt-pc-lococl         = (if out-vatp_partscl.slt-pc         = ? then 0 else out-vatp_partscl.slt-pc).
          ASSIGN   slt-base-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-base-with-tax-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl)))                           * slt-pc-lococl / (100 + slt-pc-lococl))                        vat-base-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-base-with-tax-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl))) * (1 - slt-pc-lococl / (100 + slt-pc-lococl)) * vat-pc-lococl / (100 + vat-pc-lococl)).
    ASSIGN   slt-rubl-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-rubl-with-tax-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl)))                           * slt-pc-lococl / (100 + slt-pc-lococl))                        vat-rubl-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-rubl-with-tax-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl))) * (1 - slt-pc-lococl / (100 + slt-pc-lococl)) * vat-pc-lococl / (100 + vat-pc-lococl)).
  assign
    exch-rate-cli-lococl = (out-vatp_partscl.price-rubl - transport-rubl-lococl - other-rubl-lococl - road-tax-rubl-lococl - (if out-vatp_partscl.vat-type <> 'в т. ч.':U then vat-rubl-lococl else 0) - (if out-vatp_partscl.slt-type <> 'в т. ч.':U then slt-rubl-lococl else 0)) / out-vatp_partscl.price-cli .
  assign
    slt-cli-lococl        = slt-rubl-lococl       / exch-rate-cli-lococl
    vat-cli-lococl        = vat-rubl-lococl       / exch-rate-cli-lococl
    road-tax-cli-lococl   = road-tax-rubl-lococl  / exch-rate-cli-lococl
    transport-cli-lococl  = 0
    other-cli-lococl      = 0
  .
ASSIGN
          price-base-without-tax-lococl = price-base-with-tax-lococl - vat-base-lococl - slt-base-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl))
    price-rubl-without-tax-lococl = price-rubl-with-tax-lococl - vat-rubl-lococl - slt-rubl-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl))
.
      assign
        varprice-base-conscl = varprice-base-conscl + (price-base-with-tax-lococl - (if road-tax-base-lococl = ? then 0 else road-tax-base-lococl))* out-vatp_partscl.fact-qnty
        varprice-rubl-conscl = varprice-rubl-conscl + (price-rubl-with-tax-lococl - (if road-tax-rubl-lococl = ? then 0 else road-tax-rubl-lococl))* out-vatp_partscl.fact-qnty.
      assign
        varis-cons-parts-havecl = yes
        varcons-qntycl          = varcons-qntycl + out-vatp_partscl.fact-qnty.
    end.
    assign
      varfact-qntycl = varfact-qntycl + out-vatp_partscl.fact-qnty.
  end.
end.
assign
  varprice-base-conscl = varprice-base-conscl / varcons-qntycl
  varprice-rubl-conscl = varprice-rubl-conscl / varcons-qntycl.
if varprice-base-conscl = ? then do:
  assign
    varprice-base-conscl = 0.
end.
if varprice-rubl-conscl = ? then do:
  assign
    varprice-rubl-conscl = 0.
end.
assign
  varsum-base-factovpcl     = 0
  varslt-base-factovpcl     = 0
  varvat-base-factovpcl     = 0
  varvatcons-base-factovpcl = 0
  vardsc-base-factovpcl     = 0
  varsum-base-docovpcl      = 0
  varslt-base-docovpcl      = 0
  varvat-base-docovpcl      = 0
  varvatcons-base-docovpcl  = 0
  vardsc-base-docovpcl      = 0
  varsum-rubl-factovpcl     = 0
  varslt-rubl-factovpcl     = 0
  varvat-rubl-factovpcl     = 0
  varvatcons-rubl-factovpcl = 0
  vardsc-rubl-factovpcl     = 0
  varsum-rubl-docovpcl      = 0
  varslt-rubl-docovpcl      = 0
  varvat-rubl-docovpcl      = 0
  varvatcons-rubl-docovpcl  = 0
  vardsc-rubl-docovpcl      = 0.
assign
  varis-one-gds-dtlcl = no.
find first out-vatp_gds-dtlcl where out-vatp_gds-dtlcl.doc-code  = pardoc-code  and
                                     out-vatp_gds-dtlcl.artic     = parartic     and
                                     out-vatp_gds-dtlcl.prod-type = parprod-type and
                                     out-vatp_gds-dtlcl.prod-code = parprod-code no-lock no-error.
if available out-vatp_gds-dtlcl then do:
  find first buf_out-vatp_gds-dtlcl where buf_out-vatp_gds-dtlcl.doc-code  =  pardoc-code                and
                                           buf_out-vatp_gds-dtlcl.artic     =  parartic                   and
                                           buf_out-vatp_gds-dtlcl.prod-type =  parprod-type               and
                                           buf_out-vatp_gds-dtlcl.prod-code =  parprod-code               and
                                           recid(buf_out-vatp_gds-dtlcl)    <> recid(out-vatp_gds-dtlcl) no-lock no-error.
  if not available buf_out-vatp_gds-dtlcl then do:
    assign
      varis-one-gds-dtlcl = yes.
  end.
  if varoutvprbcl = "base":u then do:
    assign
      varcurclprice-base = out-vatp_gds-dtlcl.cur-base
      varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base * ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)).
  end.
  else do:
    assign
      varcurclprice-base = out-vatp_gds-dtlcl.cur-base / ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base))
      varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base.
  end.
  if varempty-scalecl    = yes or
     varis-one-gds-dtlcl = yes   then do:
    assign
                price-base-with-tax-salecl    = (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)
        slt-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)
        vat-base-buyercl              = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)
        discnt-base-salecl            = out-vatp_gds-dtlcl.discnt-base
                price-rubl-with-tax-salecl    = (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)
        slt-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)
        vat-rubl-buyercl              = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)
        discnt-rubl-salecl            = out-vatp_gds-dtlcl.discnt-rubl
        .
    if pardoc-type = 'инв':U then do:
      ASSIGN
                vat-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
                vat-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
        .
    end.
    else do:
      ASSIGN
                vat-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl ) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
                vat-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
        .
    end.
  end.
  else do:
    for each out-vatp_gds-dtlcl where out-vatp_gds-dtlcl.doc-code  = pardoc-code  and
                                       out-vatp_gds-dtlcl.artic     = parartic     and
                                       out-vatp_gds-dtlcl.prod-type = parprod-type and
                                       out-vatp_gds-dtlcl.prod-code = parprod-code no-lock :
      if varoutvprbcl = "base":u then do:
        assign
          varcurclprice-base = out-vatp_gds-dtlcl.cur-base
          varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base * ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)).
      end.
      else do:
        assign
          varcurclprice-base = out-vatp_gds-dtlcl.cur-base / ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base))
          varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base.
      end.
      assign
             varsum-base-factovpcl = varsum-base-factovpcl + (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)                 * out-vatp_gds-dtlcl.fact-qnty
       varslt-base-factovpcl = varslt-base-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvat-base-factovpcl = varvat-base-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvatcons-base-factovpcl = varvatcons-base-factovpcl + (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-base-factovpcl = vardsc-base-factovpcl + out-vatp_gds-dtlcl.discnt-base * out-vatp_gds-dtlcl.fact-qnty
       varsum-base-docovpcl  = varsum-base-docovpcl  + (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)                 * out-vatp_gds-dtlcl.doc-qnty
       varslt-base-docovpcl  = varslt-base-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvat-base-docovpcl  = varvat-base-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvatcons-base-docovpcl  = varvatcons-base-docovpcl  + (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-base-docovpcl  = vardsc-base-docovpcl  + out-vatp_gds-dtlcl.discnt-base * out-vatp_gds-dtlcl.doc-qnty
      .
      assign
             varsum-rubl-factovpcl = varsum-rubl-factovpcl + (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)                 * out-vatp_gds-dtlcl.fact-qnty
       varslt-rubl-factovpcl = varslt-rubl-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvat-rubl-factovpcl = varvat-rubl-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvatcons-rubl-factovpcl = varvatcons-rubl-factovpcl + (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-rubl-factovpcl = vardsc-rubl-factovpcl + out-vatp_gds-dtlcl.discnt-rubl * out-vatp_gds-dtlcl.fact-qnty
       varsum-rubl-docovpcl  = varsum-rubl-docovpcl  + (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)                 * out-vatp_gds-dtlcl.doc-qnty
       varslt-rubl-docovpcl  = varslt-rubl-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvat-rubl-docovpcl  = varvat-rubl-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvatcons-rubl-docovpcl  = varvatcons-rubl-docovpcl  + (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-rubl-docovpcl  = vardsc-rubl-docovpcl  + out-vatp_gds-dtlcl.discnt-rubl * out-vatp_gds-dtlcl.doc-qnty   .
    end.
    if pardoc-type = 'инв':U then do:
      ASSIGN
                price-base-with-tax-salecl    = varsum-base-docovpcl / varfact-qntycl
        slt-base-salecl               = varslt-base-docovpcl / varfact-qntycl
        vat-base-buyercl              = varvat-base-docovpcl / varfact-qntycl
        discnt-base-salecl            = vardsc-base-docovpcl / varfact-qntycl
        vat-base-salecl               = varvatcons-base-docovpcl / varfact-qntycl
                price-rubl-with-tax-salecl    = varsum-rubl-docovpcl / varfact-qntycl
        slt-rubl-salecl               = varslt-rubl-docovpcl / varfact-qntycl
        vat-rubl-buyercl              = varvat-rubl-docovpcl / varfact-qntycl
        discnt-rubl-salecl            = vardsc-rubl-docovpcl / varfact-qntycl
        vat-rubl-salecl               = varvatcons-rubl-docovpcl / varfact-qntycl.
    end.
    else do:
      ASSIGN
                price-base-with-tax-salecl    = varsum-base-factovpcl / varfact-qntycl
        slt-base-salecl               = varslt-base-factovpcl / varfact-qntycl
        vat-base-buyercl              = varvat-base-factovpcl / varfact-qntycl
        discnt-base-salecl            = vardsc-base-factovpcl / varfact-qntycl
        vat-base-salecl               = varvatcons-base-factovpcl / varfact-qntycl
                price-rubl-with-tax-salecl    = varsum-rubl-factovpcl / varfact-qntycl
        slt-rubl-salecl               = varslt-rubl-factovpcl / varfact-qntycl
        vat-rubl-buyercl              = varvat-rubl-factovpcl / varfact-qntycl
        discnt-rubl-salecl            = vardsc-rubl-factovpcl / varfact-qntycl
        vat-rubl-salecl               = varvatcons-rubl-factovpcl / varfact-qntycl.
    end.
  end.
end.
assign
  price-base-without-tax-salecl = price-base-with-tax-salecl - vat-base-salecl - slt-base-salecl - road-tax-base-salecl
  price-rubl-without-tax-salecl = price-rubl-with-tax-salecl - vat-rubl-salecl - slt-rubl-salecl - road-tax-rubl-salecl.
end.
if paris-cur then do:
  assign
    parcurartic      = cl_tt-clcparts.artic
    parcurprod-type  = cl_tt-clcparts.prod-type
    parcurprod-code  = cl_tt-clcparts.prod-code
    parcurdoc-type   = cl_tt-clcparts.doc-type
    parcurdoc-code   = cl_tt-clcparts.out-code
    parcurobj-type   = cl_tt-clcparts.obj-type
    parcurobj-code   = cl_tt-clcparts.obj-code.
  if parr-b = "base" then do:
    assign
      parcurprice-base = parcur-base
      parcurprice-rubl = parcur-base * parbase-rate / parbase-scale.
  end.
  else do:
    assign
      parcurprice-base = parcur-base / parbase-rate * parbase-scale
      parcurprice-rubl = parcur-base.
  end.
  assign
    parcurbase-rate   = parbase-rate
    parcurbase-scale  = parbase-scale
    parcurdiscnt-base = 0
    parcurdiscnt-rubl = 0
    parcurfact-qnty   = cl_tt-clcparts.fact-qnty
    parcurcli-qnty    = cl_tt-clcparts.cli-qnty
    parcurdoc-qnty    = cl_tt-clcparts.qnty.
if parcurext-doc-type = 'ot':U or
   parcurext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltcur = yes.
end.
else do:
  find first out-vatp_doc-attrcur no-lock
    where out-vatp_doc-attrcur.doc-code  = parcurdoc-code
      and out-vatp_doc-attrcur.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attrcur then do:
    assign
      out-vatp-have-vat-sltcur = yes.
  end.
  else do:
     out-vatp-have-vat-sltcur = no.
  end.
end.
find first out-vatp_goodscur where out-vatp_goodscur.artic     = parcurartic     and
                                   out-vatp_goodscur.prod-type = parcurprod-type and
                                   out-vatp_goodscur.prod-code = parcurprod-code no-lock.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  parcurartic
  ,input  parcurprod-type
  ,input  parcurprod-code
  ,output varroot-nodecur
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" parcurartic parcurprod-type parcurprod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodecur
  ,input  'empty-scale=request'
  ,output varempty-scalecur
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" parcurartic parcurprod-type parcurprod-code skip
    "Признак" varroot-nodecur skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbcur
  )  .
if varoutvprbcur = "base":u then do:
  assign
        road-tax-base-salecur    =  (if parcurroad-tax = ? then 0 else parcurroad-tax * 1)
    excise-base-salecur      =  (if parcurexcise   = ? then 0 else parcurexcise   * 1)
  .
end.
else do:
  assign
        road-tax-base-salecur    =  (if parcurroad-tax = ? then 0 else parcurroad-tax / parcurbase-rate * parcurbase-scale)
    excise-base-salecur      =  (if parcurexcise   = ? then 0 else parcurexcise   / parcurbase-rate * parcurbase-scale)
  .
end.
if varoutvprbcur = "rubl":u then do:
  assign
        road-tax-rubl-salecur    = (if parcurroad-tax = ? then 0 else parcurroad-tax * 1)
    excise-rubl-salecur      = (if parcurexcise   = ? then 0 else parcurexcise   * 1) .
end.
else do:
  assign
        road-tax-rubl-salecur    = (if parcurroad-tax = ? then 0 else parcurroad-tax * parcurbase-rate / parcurbase-scale)
    excise-rubl-salecur      = (if parcurexcise   = ? then 0 else parcurexcise   * parcurbase-rate / parcurbase-scale) .
end.
assign
  varis-cons-parts-havecur =  no.
assign
  varfact-qntycur       = 0
  varcons-qntycur       = 0
  varprice-base-conscur = 0
  varprice-rubl-conscur = 0.
if cl_tt-clcparts.purch-code = 2 then do:
assign
  price-rubl-with-tax-lococur = cl_tt-clcparts.price-rubl
  price-base-with-tax-lococur = cl_tt-clcparts.price-base
.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbocur
  )  .
  if cl_tt-clcparts.out-code = 'free-zone':U     or
     cl_tt-clcparts.out-code = 'out-zone':U   or
     cl_tt-clcparts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltocur = yes.
  end.
  else do:
    find first in-vatp_doc-attrocur no-lock
      where in-vatp_doc-attrocur.doc-code  = cl_tt-clcparts.out-code
        and in-vatp_doc-attrocur.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrocur then do:
      assign
        in-vatp-have-vat-sltocur = yes.
    end.
    else do:
         in-vatp-have-vat-sltocur = no.
    end.
  end.
  assign
   price-cli-with-tax-lococur = cl_tt-clcparts.price-cli
   cli-base-rateocur          = cl_tt-clcparts.cli-base-rate.
  ASSIGN   road-tax-base-lococur  = (if cl_tt-clcparts.road-tax-base  = ? then 0 else cl_tt-clcparts.road-tax-base)
           road-tax-rubl-lococur  = (if cl_tt-clcparts.road-tax-rubl  = ? then 0 else cl_tt-clcparts.road-tax-rubl).
  ASSIGN  transport-base-lococur = (if cl_tt-clcparts.transport-base = ? then 0 else cl_tt-clcparts.transport-base)
          transport-rubl-lococur = (if cl_tt-clcparts.transport-rubl = ? then 0 else cl_tt-clcparts.transport-rubl)
          other-base-lococur     = (if cl_tt-clcparts.other-base     = ? then 0 else cl_tt-clcparts.other-base)
          other-rubl-lococur     = (if cl_tt-clcparts.other-rubl     = ? then 0 else cl_tt-clcparts.other-rubl)
          vat-pc-lococur         = (if cl_tt-clcparts.vat-pc         = ? then 0 else cl_tt-clcparts.vat-pc)
          slt-pc-lococur         = (if cl_tt-clcparts.slt-pc         = ? then 0 else cl_tt-clcparts.slt-pc).
          ASSIGN   slt-base-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-base-with-tax-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur)))                           * slt-pc-lococur / (100 + slt-pc-lococur))                        vat-base-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-base-with-tax-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur))) * (1 - slt-pc-lococur / (100 + slt-pc-lococur)) * vat-pc-lococur / (100 + vat-pc-lococur)).
    ASSIGN   slt-rubl-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-rubl-with-tax-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur)))                           * slt-pc-lococur / (100 + slt-pc-lococur))                        vat-rubl-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-rubl-with-tax-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur))) * (1 - slt-pc-lococur / (100 + slt-pc-lococur)) * vat-pc-lococur / (100 + vat-pc-lococur)).
  assign
    exch-rate-cli-lococur = (cl_tt-clcparts.price-rubl - transport-rubl-lococur - other-rubl-lococur - road-tax-rubl-lococur - (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-rubl-lococur else 0) - (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-rubl-lococur else 0)) / cl_tt-clcparts.price-cli .
  assign
    slt-cli-lococur        = slt-rubl-lococur       / exch-rate-cli-lococur
    vat-cli-lococur        = vat-rubl-lococur       / exch-rate-cli-lococur
    road-tax-cli-lococur   = road-tax-rubl-lococur  / exch-rate-cli-lococur
    transport-cli-lococur  = 0
    other-cli-lococur      = 0
  .
ASSIGN
          price-base-without-tax-lococur = price-base-with-tax-lococur - vat-base-lococur - slt-base-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur))
    price-rubl-without-tax-lococur = price-rubl-with-tax-lococur - vat-rubl-lococur - slt-rubl-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur))
.
  assign
    varprice-base-conscur    = varprice-base-conscur + (price-base-with-tax-lococur - (if road-tax-base-lococur = ? then 0 else road-tax-base-lococur))* cl_tt-clcparts.fact-qnty
    varprice-rubl-conscur    = varprice-rubl-conscur + (price-rubl-with-tax-lococur - (if road-tax-rubl-lococur = ? then 0 else road-tax-rubl-lococur))* cl_tt-clcparts.fact-qnty
    varis-cons-parts-havecur = yes
    varcons-qntycur          = varcons-qntycur + cl_tt-clcparts.fact-qnty.
end.
assign
  varfact-qntycur = cl_tt-clcparts.fact-qnty.
assign
  varprice-base-conscur = varprice-base-conscur / varcons-qntycur
  varprice-rubl-conscur = varprice-rubl-conscur / varcons-qntycur.
if varprice-base-conscur = ? then do:
  assign
    varprice-base-conscur = 0.
end.
if varprice-rubl-conscur = ? then do:
  assign
    varprice-rubl-conscur = 0.
end.
assign
    slt-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc)
  vat-base-buyercur              = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc)
  discnt-base-salecur            = parcurdiscnt-base
  price-base-with-tax-salecur    = (parcurprice-base - parcurdiscnt-base)
    slt-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc)
  vat-rubl-buyercur              = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc)
  discnt-rubl-salecur            = parcurdiscnt-rubl
  price-rubl-with-tax-salecur    = (parcurprice-rubl - parcurdiscnt-rubl)
  .
if parcurdoc-type = 'инв':U then do:
  assign
    varfact-qntycur = parcurdoc-qnty.
end.
else do:
  assign
    varfact-qntycur = parcurfact-qnty.
end.
if varis-cons-parts-havecur = no then do:
  assign
        vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc)
        vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc).
end.
else do:
  if parcurdoc-type = 'инв':U then do:
    assign
            vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur - varprice-base-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurdoc-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc) * parcurdoc-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
            vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur - varprice-rubl-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurdoc-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc) * parcurdoc-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
     .
  end.
  else do:
    assign
            vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur - varprice-base-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurfact-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - varprice-base-conscur) * parcurvat-pc / (100 + parcurvat-pc) * parcurfact-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
            vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur - varprice-rubl-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurfact-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - varprice-rubl-conscur) * parcurvat-pc / (100 + parcurvat-pc) * parcurfact-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
     .
  end.
end.
assign
price-base-without-tax-salecur = price-base-with-tax-salecur - vat-base-salecur - slt-base-salecur - road-tax-base-salecur
price-rubl-without-tax-salecur = price-rubl-with-tax-salecur - vat-rubl-salecur - slt-rubl-salecur - road-tax-rubl-salecur.
end.
create bf_tt-allsum.
assign
  bf_tt-allsum.sum-type = 'основная_сумма':U.
assign
  bf_tt-allsum.fact-qnty          =  cl_tt-clcparts.fact-qnty
  bf_tt-allsum.cli-qnty           =  cl_tt-clcparts.cli-qnty
  bf_tt-allsum.sum-dsc-base-doc   =  (if price-base-with-tax-salecl  = ? then 0 else price-base-with-tax-salecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-doc   =  (if price-rubl-with-tax-salecl  = ? then 0 else price-rubl-with-tax-salecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-doc       =  (if discnt-base-salecl          = ? then 0 else discnt-base-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-rubl-doc       =  (if discnt-rubl-salecl          = ? then 0 else discnt-rubl-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-doc       =  (if slt-base-salecl             = ? then 0 else slt-base-salecl             * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-doc       =  (if slt-rubl-salecl             = ? then 0 else slt-rubl-salecl             * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-base-buyer-doc =  (if vat-base-buyercl            = ? then 0 else vat-base-buyercl            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-buyer-doc =  (if vat-rubl-buyercl            = ? then 0 else vat-rubl-buyercl            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-doc  =  (if road-tax-base-salecl        = ? then 0 else road-tax-base-salecl        * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-doc  =  (if road-tax-rubl-salecl        = ? then 0 else road-tax-rubl-salecl        * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-doc    =  (if excise-base-salecl          = ? then 0 else excise-base-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-rubl-doc    =  (if excise-rubl-salecl          = ? then 0 else excise-rubl-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-base-cur   =  (if price-base-with-tax-salecur = ? then 0 else price-base-with-tax-salecur * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-cur   =  (if price-rubl-with-tax-salecur = ? then 0 else price-rubl-with-tax-salecur * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-cur       =  (if discnt-base-salecur         = ? then 0 else discnt-base-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-rubl-cur       =  (if discnt-rubl-salecur         = ? then 0 else discnt-rubl-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-cur       =  (if slt-base-salecur            = ? then 0 else slt-base-salecur            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-cur       =  (if slt-rubl-salecur            = ? then 0 else slt-rubl-salecur            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-base-buyer-cur =  (if vat-base-buyercur           = ? then 0 else vat-base-buyercur           * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-buyer-cur =  (if vat-rubl-buyercur           = ? then 0 else vat-rubl-buyercur           * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-cur  =  (if road-tax-base-salecur       = ? then 0 else road-tax-base-salecur       * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-cur  =  (if road-tax-rubl-salecur       = ? then 0 else road-tax-rubl-salecur       * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-cur    =  (if excise-base-salecur         = ? then 0 else excise-base-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-rubl-cur    =  (if excise-rubl-salecur         = ? then 0 else excise-rubl-salecur         * cl_tt-clcparts.fact-qnty)
  .
if cl_tt-clcparts.purch-code = integer('2':U) then do:
  assign
    bf_tt-allsum.vat-base-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecl  - road-tax-base-salecl  - slt-base-salecl  - (cl_tt-clcparts.price-base - cl_tt-clcparts.road-tax-base)) * parcons-vat-pc / (100 + parcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecl  - road-tax-rubl-salecl  - slt-rubl-salecl  - (cl_tt-clcparts.price-rubl - cl_tt-clcparts.road-tax-rubl)) * parcons-vat-pc / (100 + parcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-base-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecur - road-tax-base-salecur - slt-base-salecur - (cl_tt-clcparts.price-base - cl_tt-clcparts.road-tax-base)) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecur - road-tax-rubl-salecur - slt-rubl-salecur - (cl_tt-clcparts.price-rubl - cl_tt-clcparts.road-tax-rubl)) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    .
end.
else do:
  assign
    bf_tt-allsum.vat-base-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecl  - road-tax-base-salecl  - slt-base-salecl ) * parvat-pc / (100 + parvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecl  - road-tax-rubl-salecl  - slt-rubl-salecl ) * parvat-pc / (100 + parvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-base-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecur - road-tax-base-salecur - slt-base-salecur) * parcurvat-pc / (100 + parcurvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecur - road-tax-rubl-salecur - slt-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc) * cl_tt-clcparts.fact-qnty)
    .
end.
if bf_tt-allsum.vat-base-doc = ? then bf_tt-allsum.vat-base-doc = 0.
if bf_tt-allsum.vat-rubl-doc = ? then bf_tt-allsum.vat-rubl-doc = 0.
assign
  bf_tt-allsum.sum-dsc-base-acc     = (if price-base-with-tax-loccl    = ? then 0 else price-base-with-tax-loccl    * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-acc     = (if price-rubl-with-tax-loccl    = ? then 0 else price-rubl-with-tax-loccl    * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-cli-acc      = (if (price-cli-with-tax-loccl +
                                           road-tax-cli-loccl       +
                                           (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-cli-loccl else 0) +
                                           (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-cli-loccl else 0)
                                           ) / cli-base-ratecl = ? then 0
                                        else
                                          (price-cli-with-tax-loccl +
                                           road-tax-cli-loccl       +
                                           (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-cli-loccl else 0) +
                                           (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-cli-loccl else 0)
                                           ) / cli-base-ratecl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-acc         = 0
  bf_tt-allsum.dsc-rubl-acc         = 0
  bf_tt-allsum.dsc-cli-acc          = 0
  bf_tt-allsum.vat-base-acc         = (if vat-base-loccl      = ? then 0 else vat-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-acc         = (if vat-rubl-loccl      = ? then 0 else vat-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-cli-acc          = (if vat-cli-loccl / cli-base-ratecl      = ? then 0 else vat-cli-loccl / cli-base-ratecl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-acc         = (if slt-base-loccl      = ? then 0 else slt-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-acc         = (if slt-rubl-loccl      = ? then 0 else slt-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-cli-acc          = (if slt-cli-loccl / cli-base-ratecl      = ? then 0 else slt-cli-loccl / cli-base-ratecl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-acc    = (if road-tax-base-loccl = ? then 0 else road-tax-base-loccl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-acc    = (if road-tax-rubl-loccl = ? then 0 else road-tax-rubl-loccl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-cli-acc     = (if road-tax-cli-loccl / cli-base-ratecl = ? then 0 else road-tax-cli-loccl / cli-base-ratecl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-acc      = 0
  bf_tt-allsum.excise-rubl-acc      = 0
  bf_tt-allsum.excise-cli-acc       = 0
  bf_tt-allsum.transport-base-acc   = (if transport-base-loccl   = ? then 0 else transport-base-loccl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.transport-rubl-acc   = (if transport-rubl-loccl   = ? then 0 else transport-rubl-loccl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.transport-cli-acc    = (if transport-cli-loccl / cli-base-ratecl   = ? then 0 else transport-cli-loccl / cli-base-ratecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-base-acc       = (if other-base-loccl       = ? then 0 else other-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-rubl-acc       = (if other-rubl-loccl       = ? then 0 else other-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-cli-acc        = (if other-cli-loccl / cli-base-ratecl       = ? then 0 else other-cli-loccl     / cli-base-ratecl  * cl_tt-clcparts.fact-qnty).
create bfs_tt-allsum.
assign
  bfs_tt-allsum.sum-type = 'основная_сумма_со_знаком':U.
if pardoc-type = 'инв':U or
   pardoc-type = 'при':U    or
   pardoc-type = 'возврат':U    then do:
   buffer-copy bf_tt-allsum except bf_tt-allsum.sum-type to bfs_tt-allsum.
end.
else do:
  assign
    bfs_tt-allsum.fact-qnty           =  - bf_tt-allsum.fact-qnty
    bfs_tt-allsum.cli-qnty            =  - bf_tt-allsum.cli-qnty
    bfs_tt-allsum.sum-dsc-base-doc    =  - bf_tt-allsum.sum-dsc-base-doc
    bfs_tt-allsum.sum-dsc-rubl-doc    =  - bf_tt-allsum.sum-dsc-rubl-doc
    bfs_tt-allsum.dsc-base-doc        =  - bf_tt-allsum.dsc-base-doc
    bfs_tt-allsum.dsc-rubl-doc        =  - bf_tt-allsum.dsc-rubl-doc
    bfs_tt-allsum.vat-base-doc        =  - bf_tt-allsum.vat-base-doc
    bfs_tt-allsum.vat-rubl-doc        =  - bf_tt-allsum.vat-rubl-doc
    bfs_tt-allsum.vat-base-buyer-doc  =  - bf_tt-allsum.vat-base-buyer-doc
    bfs_tt-allsum.vat-rubl-buyer-doc  =  - bf_tt-allsum.vat-rubl-buyer-doc
    bfs_tt-allsum.slt-base-doc        =  - bf_tt-allsum.slt-base-doc
    bfs_tt-allsum.slt-rubl-doc        =  - bf_tt-allsum.slt-rubl-doc
    bfs_tt-allsum.road-tax-base-doc   =  - bf_tt-allsum.road-tax-base-doc
    bfs_tt-allsum.road-tax-rubl-doc   =  - bf_tt-allsum.road-tax-rubl-doc
    bfs_tt-allsum.excise-base-doc     =  - bf_tt-allsum.excise-base-doc
    bfs_tt-allsum.excise-rubl-doc     =  - bf_tt-allsum.excise-rubl-doc
    bfs_tt-allsum.sum-dsc-base-cur    =  - bf_tt-allsum.sum-dsc-base-cur
    bfs_tt-allsum.sum-dsc-rubl-cur    =  - bf_tt-allsum.sum-dsc-rubl-cur
    bfs_tt-allsum.dsc-base-cur        =  - bf_tt-allsum.dsc-base-cur
    bfs_tt-allsum.dsc-rubl-cur        =  - bf_tt-allsum.dsc-rubl-cur
    bfs_tt-allsum.vat-base-cur        =  - bf_tt-allsum.vat-base-cur
    bfs_tt-allsum.vat-rubl-cur        =  - bf_tt-allsum.vat-rubl-cur
    bfs_tt-allsum.vat-base-buyer-cur  =  - bf_tt-allsum.vat-base-buyer-cur
    bfs_tt-allsum.vat-rubl-buyer-cur  =  - bf_tt-allsum.vat-rubl-buyer-cur
    bfs_tt-allsum.slt-base-cur        =  - bf_tt-allsum.slt-base-cur
    bfs_tt-allsum.slt-rubl-cur        =  - bf_tt-allsum.slt-rubl-cur
    bfs_tt-allsum.road-tax-base-cur   =  - bf_tt-allsum.road-tax-base-cur
    bfs_tt-allsum.road-tax-rubl-cur   =  - bf_tt-allsum.road-tax-rubl-cur
    bfs_tt-allsum.excise-base-cur     =  - bf_tt-allsum.excise-base-cur
    bfs_tt-allsum.excise-rubl-cur     =  - bf_tt-allsum.excise-rubl-cur
    bfs_tt-allsum.sum-dsc-base-acc    =  - bf_tt-allsum.sum-dsc-base-acc
    bfs_tt-allsum.sum-dsc-rubl-acc    =  - bf_tt-allsum.sum-dsc-rubl-acc
    bfs_tt-allsum.sum-dsc-cli-acc     =  - bf_tt-allsum.sum-dsc-cli-acc
    bfs_tt-allsum.dsc-base-acc        =  - bf_tt-allsum.dsc-base-acc
    bfs_tt-allsum.dsc-rubl-acc        =  - bf_tt-allsum.dsc-rubl-acc
    bfs_tt-allsum.dsc-cli-acc         =  - bf_tt-allsum.dsc-cli-acc
    bfs_tt-allsum.vat-base-acc        =  - bf_tt-allsum.vat-base-acc
    bfs_tt-allsum.vat-rubl-acc        =  - bf_tt-allsum.vat-rubl-acc
    bfs_tt-allsum.vat-cli-acc         =  - bf_tt-allsum.vat-cli-acc
    bfs_tt-allsum.slt-base-acc        =  - bf_tt-allsum.slt-base-acc
    bfs_tt-allsum.slt-rubl-acc        =  - bf_tt-allsum.slt-rubl-acc
    bfs_tt-allsum.slt-cli-acc         =  - bf_tt-allsum.slt-cli-acc
    bfs_tt-allsum.road-tax-base-acc   =  - bf_tt-allsum.road-tax-base-acc
    bfs_tt-allsum.road-tax-rubl-acc   =  - bf_tt-allsum.road-tax-rubl-acc
    bfs_tt-allsum.road-tax-cli-acc    =  - bf_tt-allsum.road-tax-cli-acc
    bfs_tt-allsum.excise-base-acc     =  - bf_tt-allsum.excise-base-acc
    bfs_tt-allsum.excise-rubl-acc     =  - bf_tt-allsum.excise-rubl-acc
    bfs_tt-allsum.excise-cli-acc      =  - bf_tt-allsum.excise-cli-acc
    bfs_tt-allsum.transport-base-acc  =  - bf_tt-allsum.transport-base-acc
    bfs_tt-allsum.transport-rubl-acc  =  - bf_tt-allsum.transport-rubl-acc
    bfs_tt-allsum.transport-cli-acc   =  - bf_tt-allsum.transport-cli-acc
    bfs_tt-allsum.other-base-acc      =  - bf_tt-allsum.other-base-acc
    bfs_tt-allsum.other-rubl-acc      =  - bf_tt-allsum.other-rubl-acc
    bfs_tt-allsum.other-cli-acc       =  - bf_tt-allsum.other-cli-acc.
end.
create bfpc_tt-allsum.
create bfspc_tt-allsum.
case cl_tt-clcparts.purch-code :
when 1           then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_выкупу':U
    bfspc_tt-allsum.sum-type = 'сумма_по_выкупу_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 4    then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_старой_консигнации':U
    bfspc_tt-allsum.sum-type = 'сумма_по_старой_консигнации_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 3 then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_ответственному_хранению':U
    bfspc_tt-allsum.sum-type = 'сумма_по_ответственному_хранению_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 2 then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_консигнации_выгода':U
    bfspc_tt-allsum.sum-type = 'сумма_по_консигнации_выгода_со_знаком':U.
  assign
    bfpc_tt-allsum.fact-qnty           = bf_tt-allsum.fact-qnty
    bfpc_tt-allsum.cli-qnty            = bf_tt-allsum.cli-qnty
    bfpc_tt-allsum.sum-dsc-base-doc    = bf_tt-allsum.sum-dsc-base-doc    - bf_tt-allsum.sum-dsc-base-acc
    bfpc_tt-allsum.sum-dsc-rubl-doc    = bf_tt-allsum.sum-dsc-rubl-doc    - bf_tt-allsum.sum-dsc-rubl-acc
    bfpc_tt-allsum.dsc-base-doc        = bf_tt-allsum.dsc-base-doc        - bf_tt-allsum.dsc-base-acc
    bfpc_tt-allsum.dsc-rubl-doc        = bf_tt-allsum.dsc-rubl-doc        - bf_tt-allsum.dsc-rubl-acc
    bfpc_tt-allsum.vat-base-doc        = bf_tt-allsum.vat-base-doc
    bfpc_tt-allsum.vat-rubl-doc        = bf_tt-allsum.vat-rubl-doc
    bfpc_tt-allsum.vat-base-buyer-doc  = bf_tt-allsum.vat-base-buyer-doc  - bf_tt-allsum.vat-base-acc
    bfpc_tt-allsum.vat-rubl-buyer-doc  = bf_tt-allsum.vat-rubl-buyer-doc  - bf_tt-allsum.vat-rubl-acc
    bfpc_tt-allsum.slt-base-doc        = bf_tt-allsum.slt-base-doc        - bf_tt-allsum.slt-base-acc
    bfpc_tt-allsum.slt-rubl-doc        = bf_tt-allsum.slt-rubl-doc        - bf_tt-allsum.slt-rubl-acc
    bfpc_tt-allsum.road-tax-base-doc   = bf_tt-allsum.road-tax-base-doc   - bf_tt-allsum.road-tax-base-acc
    bfpc_tt-allsum.road-tax-rubl-doc   = bf_tt-allsum.road-tax-rubl-doc   - bf_tt-allsum.road-tax-rubl-acc
    bfpc_tt-allsum.excise-base-doc     = bf_tt-allsum.excise-base-doc
    bfpc_tt-allsum.excise-rubl-doc     = bf_tt-allsum.excise-rubl-doc
    bfpc_tt-allsum.sum-dsc-base-cur    = bf_tt-allsum.sum-dsc-base-cur    - bf_tt-allsum.sum-dsc-base-acc
    bfpc_tt-allsum.sum-dsc-rubl-cur    = bf_tt-allsum.sum-dsc-rubl-cur    - bf_tt-allsum.sum-dsc-rubl-acc
    bfpc_tt-allsum.dsc-base-cur        = bf_tt-allsum.dsc-base-cur        - bf_tt-allsum.dsc-base-acc
    bfpc_tt-allsum.dsc-rubl-cur        = bf_tt-allsum.dsc-rubl-cur        - bf_tt-allsum.dsc-rubl-acc
    bfpc_tt-allsum.vat-base-cur        = bf_tt-allsum.vat-base-cur
    bfpc_tt-allsum.vat-rubl-cur        = bf_tt-allsum.vat-rubl-cur
    bfpc_tt-allsum.vat-base-buyer-cur  = bf_tt-allsum.vat-base-buyer-cur  - bf_tt-allsum.vat-base-acc
    bfpc_tt-allsum.vat-rubl-buyer-cur  = bf_tt-allsum.vat-rubl-buyer-cur  - bf_tt-allsum.vat-rubl-acc
    bfpc_tt-allsum.slt-base-cur        = bf_tt-allsum.slt-base-cur        - bf_tt-allsum.slt-base-acc
    bfpc_tt-allsum.slt-rubl-cur        = bf_tt-allsum.slt-rubl-cur        - bf_tt-allsum.slt-rubl-acc
    bfpc_tt-allsum.road-tax-base-cur   = bf_tt-allsum.road-tax-base-cur   - bf_tt-allsum.road-tax-base-acc
    bfpc_tt-allsum.road-tax-rubl-cur   = bf_tt-allsum.road-tax-rubl-cur   - bf_tt-allsum.road-tax-rubl-acc
    bfpc_tt-allsum.excise-base-cur     = bf_tt-allsum.excise-base-cur
    bfpc_tt-allsum.excise-rubl-cur     = bf_tt-allsum.excise-rubl-cur
    bfpc_tt-allsum.sum-dsc-base-acc    = 0
    bfpc_tt-allsum.sum-dsc-rubl-acc    = 0
    bfpc_tt-allsum.sum-dsc-cli-acc     = 0
    bfpc_tt-allsum.dsc-base-acc        = 0
    bfpc_tt-allsum.dsc-rubl-acc        = 0
    bfpc_tt-allsum.dsc-cli-acc         = 0
    bfpc_tt-allsum.vat-base-acc        = 0
    bfpc_tt-allsum.vat-rubl-acc        = 0
    bfpc_tt-allsum.vat-cli-acc         = 0
    bfpc_tt-allsum.slt-base-acc        = 0
    bfpc_tt-allsum.slt-rubl-acc        = 0
    bfpc_tt-allsum.slt-cli-acc         = 0
    bfpc_tt-allsum.road-tax-base-acc   = 0
    bfpc_tt-allsum.road-tax-rubl-acc   = 0
    bfpc_tt-allsum.road-tax-cli-acc    = 0
    bfpc_tt-allsum.excise-base-acc     = 0
    bfpc_tt-allsum.excise-rubl-acc     = 0
    bfpc_tt-allsum.excise-cli-acc      = 0
    bfpc_tt-allsum.transport-base-acc  = 0
    bfpc_tt-allsum.transport-rubl-acc  = 0
    bfpc_tt-allsum.transport-cli-acc   = 0
    bfpc_tt-allsum.other-base-acc      = 0
    bfpc_tt-allsum.other-rubl-acc      = 0
    bfpc_tt-allsum.other-cli-acc       = 0
    .
  assign
    bfspc_tt-allsum.fact-qnty           = bfs_tt-allsum.fact-qnty
    bfspc_tt-allsum.cli-qnty            = bfs_tt-allsum.cli-qnty
    bfspc_tt-allsum.sum-dsc-base-doc    = bfs_tt-allsum.sum-dsc-base-doc    - bfs_tt-allsum.sum-dsc-base-acc
    bfspc_tt-allsum.sum-dsc-rubl-doc    = bfs_tt-allsum.sum-dsc-rubl-doc    - bfs_tt-allsum.sum-dsc-rubl-acc
    bfspc_tt-allsum.dsc-base-doc        = bfs_tt-allsum.dsc-base-doc        - bfs_tt-allsum.dsc-base-acc
    bfspc_tt-allsum.dsc-rubl-doc        = bfs_tt-allsum.dsc-rubl-doc        - bfs_tt-allsum.dsc-rubl-acc
    bfspc_tt-allsum.vat-base-doc        = bfs_tt-allsum.vat-base-doc
    bfspc_tt-allsum.vat-rubl-doc        = bfs_tt-allsum.vat-rubl-doc
    bfspc_tt-allsum.vat-base-buyer-doc  = bfs_tt-allsum.vat-base-buyer-doc  - bfs_tt-allsum.vat-base-acc
    bfspc_tt-allsum.vat-rubl-buyer-doc  = bfs_tt-allsum.vat-rubl-buyer-doc  - bfs_tt-allsum.vat-rubl-acc
    bfspc_tt-allsum.slt-base-doc        = bfs_tt-allsum.slt-base-doc        - bfs_tt-allsum.slt-base-acc
    bfspc_tt-allsum.slt-rubl-doc        = bfs_tt-allsum.slt-rubl-doc        - bfs_tt-allsum.slt-rubl-acc
    bfspc_tt-allsum.road-tax-base-doc   = bfs_tt-allsum.road-tax-base-doc   - bfs_tt-allsum.road-tax-base-acc
    bfspc_tt-allsum.road-tax-rubl-doc   = bfs_tt-allsum.road-tax-rubl-doc   - bfs_tt-allsum.road-tax-rubl-acc
    bfspc_tt-allsum.excise-base-doc     = bfs_tt-allsum.excise-base-doc
    bfspc_tt-allsum.excise-rubl-doc     = bfs_tt-allsum.excise-rubl-doc
    bfspc_tt-allsum.sum-dsc-base-cur    = bfs_tt-allsum.sum-dsc-base-cur    - bfs_tt-allsum.sum-dsc-base-acc
    bfspc_tt-allsum.sum-dsc-rubl-cur    = bfs_tt-allsum.sum-dsc-rubl-cur    - bfs_tt-allsum.sum-dsc-rubl-acc
    bfspc_tt-allsum.dsc-base-cur        = bfs_tt-allsum.dsc-base-cur        - bfs_tt-allsum.dsc-base-acc
    bfspc_tt-allsum.dsc-rubl-cur        = bfs_tt-allsum.dsc-rubl-cur        - bfs_tt-allsum.dsc-rubl-acc
    bfspc_tt-allsum.vat-base-cur        = bfs_tt-allsum.vat-base-cur
    bfspc_tt-allsum.vat-rubl-cur        = bfs_tt-allsum.vat-rubl-cur
    bfspc_tt-allsum.vat-base-buyer-cur  = bfs_tt-allsum.vat-base-buyer-cur  - bfs_tt-allsum.vat-base-acc
    bfspc_tt-allsum.vat-rubl-buyer-cur  = bfs_tt-allsum.vat-rubl-buyer-cur  - bfs_tt-allsum.vat-rubl-acc
    bfspc_tt-allsum.slt-base-cur        = bfs_tt-allsum.slt-base-cur        - bfs_tt-allsum.slt-base-acc
    bfspc_tt-allsum.slt-rubl-cur        = bfs_tt-allsum.slt-rubl-cur        - bfs_tt-allsum.slt-rubl-acc
    bfspc_tt-allsum.road-tax-base-cur   = bfs_tt-allsum.road-tax-base-cur   - bfs_tt-allsum.road-tax-base-acc
    bfspc_tt-allsum.road-tax-rubl-cur   = bfs_tt-allsum.road-tax-rubl-cur   - bfs_tt-allsum.road-tax-rubl-acc
    bfspc_tt-allsum.excise-base-cur     = bfs_tt-allsum.excise-base-cur
    bfspc_tt-allsum.excise-rubl-cur     = bfs_tt-allsum.excise-rubl-cur
    bfspc_tt-allsum.sum-dsc-base-acc    = 0
    bfspc_tt-allsum.sum-dsc-rubl-acc    = 0
    bfspc_tt-allsum.sum-dsc-cli-acc     = 0
    bfspc_tt-allsum.dsc-base-acc        = 0
    bfspc_tt-allsum.dsc-rubl-acc        = 0
    bfspc_tt-allsum.dsc-cli-acc         = 0
    bfspc_tt-allsum.vat-base-acc        = 0
    bfspc_tt-allsum.vat-rubl-acc        = 0
    bfspc_tt-allsum.vat-cli-acc         = 0
    bfspc_tt-allsum.slt-base-acc        = 0
    bfspc_tt-allsum.slt-rubl-acc        = 0
    bfspc_tt-allsum.slt-cli-acc         = 0
    bfspc_tt-allsum.road-tax-base-acc   = 0
    bfspc_tt-allsum.road-tax-rubl-acc   = 0
    bfspc_tt-allsum.road-tax-cli-acc    = 0
    bfspc_tt-allsum.excise-base-acc     = 0
    bfspc_tt-allsum.excise-rubl-acc     = 0
    bfspc_tt-allsum.excise-cli-acc      = 0
    bfspc_tt-allsum.transport-base-acc  = 0
    bfspc_tt-allsum.transport-rubl-acc  = 0
    bfspc_tt-allsum.transport-cli-acc   = 0
    bfspc_tt-allsum.other-base-acc      = 0
    bfspc_tt-allsum.other-rubl-acc      = 0
    bfspc_tt-allsum.other-cli-acc       = 0
    .
  create bfacc_tt-allsum.
  assign
    bfacc_tt-allsum.sum-type = 'сумма_по_консигнации_закупка':U.
  create bfsacc_tt-allsum.
  assign
    bfsacc_tt-allsum.sum-type = 'сумма_по_консигнации_закупка_со_знаком':U.
  assign
    bfacc_tt-allsum.fact-qnty           = bf_tt-allsum.fact-qnty
    bfacc_tt-allsum.cli-qnty            = bf_tt-allsum.cli-qnty
    bfacc_tt-allsum.sum-dsc-base-doc    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-doc    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.dsc-base-doc        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-doc        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.vat-base-doc        = 0
    bfacc_tt-allsum.vat-rubl-doc        = 0
    bfacc_tt-allsum.vat-base-buyer-doc  = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-buyer-doc  = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.slt-base-doc        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-doc        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.road-tax-base-doc   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-doc   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.excise-base-doc     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-doc     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.sum-dsc-base-cur    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-cur    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.dsc-base-cur        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-cur        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.vat-base-cur        = 0
    bfacc_tt-allsum.vat-rubl-cur        = 0
    bfacc_tt-allsum.vat-base-buyer-cur  = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-buyer-cur  = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.slt-base-cur        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-cur        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.road-tax-base-cur   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-cur   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.excise-base-cur     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-cur     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.sum-dsc-base-acc    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-acc    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.sum-dsc-cli-acc     = bf_tt-allsum.sum-dsc-cli-acc
    bfacc_tt-allsum.dsc-base-acc        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-acc        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.dsc-cli-acc         = bf_tt-allsum.dsc-cli-acc
    bfacc_tt-allsum.vat-base-acc        = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-acc        = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.vat-cli-acc         = bf_tt-allsum.vat-cli-acc
    bfacc_tt-allsum.slt-base-acc        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-acc        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.slt-cli-acc         = bf_tt-allsum.slt-cli-acc
    bfacc_tt-allsum.excise-base-acc     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-acc     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.excise-cli-acc      = bf_tt-allsum.excise-cli-acc
    bfacc_tt-allsum.road-tax-base-acc   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-acc   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.road-tax-cli-acc    = bf_tt-allsum.road-tax-cli-acc
    bfacc_tt-allsum.transport-base-acc  = bf_tt-allsum.transport-base-acc
    bfacc_tt-allsum.transport-rubl-acc  = bf_tt-allsum.transport-rubl-acc
    bfacc_tt-allsum.transport-cli-acc   = bf_tt-allsum.transport-cli-acc
    bfacc_tt-allsum.other-base-acc      = bf_tt-allsum.other-base-acc
    bfacc_tt-allsum.other-rubl-acc      = bf_tt-allsum.other-rubl-acc
    bfacc_tt-allsum.other-cli-acc       = bf_tt-allsum.other-cli-acc
    .
  assign
    bfsacc_tt-allsum.fact-qnty           = bfs_tt-allsum.fact-qnty
    bfsacc_tt-allsum.cli-qnty            = bfs_tt-allsum.cli-qnty
    bfsacc_tt-allsum.sum-dsc-base-doc    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-doc    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.dsc-base-doc        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-doc        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.vat-base-doc        = 0
    bfsacc_tt-allsum.vat-rubl-doc        = 0
    bfsacc_tt-allsum.vat-base-buyer-doc  = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-buyer-doc  = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.slt-base-doc        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-doc        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.road-tax-base-doc   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-doc   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.excise-base-doc     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-doc     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.sum-dsc-base-cur    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-cur    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.dsc-base-cur        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-cur        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.vat-base-cur        = 0
    bfsacc_tt-allsum.vat-rubl-cur        = 0
    bfsacc_tt-allsum.vat-base-buyer-cur  = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-buyer-cur  = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.slt-base-cur        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-cur        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.road-tax-base-cur   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-cur   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.excise-base-cur     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-cur     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.sum-dsc-base-acc    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-acc    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.sum-dsc-cli-acc     = bfs_tt-allsum.sum-dsc-cli-acc
    bfsacc_tt-allsum.dsc-base-acc        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-acc        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.dsc-cli-acc         = bfs_tt-allsum.dsc-cli-acc
    bfsacc_tt-allsum.vat-base-acc        = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-acc        = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.vat-cli-acc         = bfs_tt-allsum.vat-cli-acc
    bfsacc_tt-allsum.slt-base-acc        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-acc        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.slt-cli-acc         = bfs_tt-allsum.slt-cli-acc
    bfsacc_tt-allsum.excise-base-acc     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-acc     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.excise-cli-acc      = bfs_tt-allsum.excise-cli-acc
    bfsacc_tt-allsum.road-tax-base-acc   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-acc   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.road-tax-cli-acc    = bfs_tt-allsum.road-tax-cli-acc
    bfsacc_tt-allsum.transport-base-acc  = bfs_tt-allsum.transport-base-acc
    bfsacc_tt-allsum.transport-rubl-acc  = bfs_tt-allsum.transport-rubl-acc
    bfsacc_tt-allsum.transport-cli-acc   = bfs_tt-allsum.transport-cli-acc
    bfsacc_tt-allsum.other-base-acc      = bfs_tt-allsum.other-base-acc
    bfsacc_tt-allsum.other-rubl-acc      = bfs_tt-allsum.other-rubl-acc
    bfsacc_tt-allsum.other-cli-acc       = bfs_tt-allsum.other-cli-acc
    .
end.
otherwise do:
  return error substitute ("Неизвестный тип приобретения &1 по партии с кодом &2 по документу &3, порожденную документом &4 по товару &5 &6 &7.",
                           cl_tt-clcparts.purch-code,
                           cl_tt-clcparts.part-code,
                           cl_tt-clcparts.out-code,
                           cl_tt-clcparts.in-code,
                           cl_tt-clcparts.artic,
                           cl_tt-clcparts.prod-type,
                           cl_tt-clcparts.prod-code).
end.
end case.
end.
end procedure.
procedure clcprtsl_calc-line :
define input  parameter parrec-line as recid no-undo.
define variable v-tax-date         as   date                     no-undo.
define variable v-vat-pc           like ub.doc-line.vat-pc       no-undo.
define variable varr-b             as   character                no-undo.
define variable varr-btype         as   character                no-undo.
define variable varcur-base        like ub.gds-dtl.price-base    no-undo.
define variable varcur-road-tax    like ub.doc-line.road-tax     no-undo.
define variable varcur-excise      like ub.doc-line.excise       no-undo.
define variable varcur-vat-pc      like ub.doc-line.vat-pc       no-undo.
define variable varcur-cons-vat-pc like ub.doc-line.cons-vat-pc  no-undo.
define variable varcur-slt-pc      like ub.doc-line.slt-pc       no-undo.
define variable varcur-fact-qnty   like ub.gds-dtl.fact-qnty     no-undo.
define variable varb-code          like ub.bar-code.b-code       no-undo.
define variable vardoc-num         like ub.price-doc.doc-num     no-undo.
define variable varprice-sale      like ub.price-list.price-sale no-undo.
define variable varroad-tax        like ub.price-list.road-tax   no-undo.
define variable varexcise          like ub.price-list.excise     no-undo.
define variable varlastcur-base        like ub.gds-dtl.price-base no-undo.
define variable varlastcur-road-tax    like ub.gds-dtl.price-base no-undo.
define variable varlastcur-excise      like ub.gds-dtl.price-base     no-undo.
define variable v-b-pcode          like ub.bar-code.b-code     no-undo.
define variable v-varsum           as decimal                  no-undo.
define variable varprice-salef as decimal   no-undo .
define buffer bf_trn-doc             for ub.trn-doc.
define buffer bf_doc-line            for ub.doc-line.
define buffer bf_gds-dtl             for ub.gds-dtl.
define buffer bf_goods               for ub.goods.
define buffer bf_parts               for ub.parts.
define buffer bf_sysconf             for ub.sysconf.
define buffer bf_tt-allsum-line      for tt-allsum-line.
define buffer bfs_tt-allsum-line     for tt-allsum-line.
define buffer bfo_tt-allsum-line     for tt-allsum-line.
define buffer bfos_tt-allsum-line    for tt-allsum-line.
define buffer buf_parts        for ub.parts.
v-calcbypart = no.
do on error undo, return error return-value :
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
  find first bf_doc-line where recid (bf_doc-line) = parrec-line no-lock.
  find first bf_trn-doc where bf_trn-doc.doc-code = bf_doc-line.doc-code no-lock.
  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock.
  if bf_trn-doc.fact-date <> ?        then do:
    assign v-tax-date = bf_trn-doc.fact-date.
  end.
  else do:
    assign v-tax-date = ?.
  end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf_goods.gds-code
  ,input  '1':U
  ,input  v-tax-date
  ,input  bf_trn-doc.host-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output v-vat-pc
  ) no-error .
  if error-status :error
  or v-vat-pc = ? then do:
     return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
  end.
  if bf_goods.gds-type = 'у':U or
     bf_trn-doc.status_ = 'запрос':U then do:
    for each bf_tt-allsum-line
    on error undo, return error return-value
     :
      delete bf_tt-allsum-line.
    end.
    create bf_tt-allsum-line.
    assign
     bf_tt-allsum-line.sum-type = 'основная_сумма':U.
    for each bf_gds-dtl where bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
                              bf_gds-dtl.artic     = bf_doc-line.artic     and
                              bf_gds-dtl.prod-type = bf_doc-line.prod-type and
                              bf_gds-dtl.prod-code = bf_doc-line.prod-code no-lock on error undo, return error return-value :
      assign
        bf_tt-allsum-line.fact-qnty            =  bf_tt-allsum-line.fact-qnty        + bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-doc     =  bf_tt-allsum-line.sum-dsc-base-doc + (bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-doc     =  bf_tt-allsum-line.sum-dsc-rubl-doc + (bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.dsc-base-doc         =  bf_tt-allsum-line.dsc-base-doc     + bf_gds-dtl.discnt-base * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.dsc-rubl-doc         =  bf_tt-allsum-line.dsc-rubl-doc     + bf_gds-dtl.discnt-rubl * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-cur     =  bf_tt-allsum-line.sum-dsc-base-cur + (if varr-b = "base" then bf_gds-dtl.cur-base else bf_gds-dtl.cur-base / bf_trn-doc.exch-rate * bf_trn-doc.exch-scale) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-cur     =  bf_tt-allsum-line.sum-dsc-rubl-cur + (if varr-b = "rubl" then bf_gds-dtl.cur-base else bf_gds-dtl.cur-base * bf_trn-doc.exch-rate / bf_trn-doc.exch-scale) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-acc     =  bf_tt-allsum-line.sum-dsc-base-acc + bf_doc-line.price-base * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-acc     =  bf_tt-allsum-line.sum-dsc-rubl-acc + bf_doc-line.price-rubl * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-cli-acc      =  ?
        bf_tt-allsum-line.vat-base-acc         =  bf_tt-allsum-line.vat-base-acc     + bf_doc-line.price-base * v-vat-pc / (100 + v-vat-pc) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.vat-rubl-acc         =  bf_tt-allsum-line.vat-rubl-acc     + bf_doc-line.price-rubl * v-vat-pc / (100 + v-vat-pc) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.vat-cli-acc          =  ?
        .
    end.
    assign
      bf_tt-allsum-line.cli-qnty             =  ?
      bf_tt-allsum-line.slt-base-doc         =  bf_tt-allsum-line.sum-dsc-base-doc * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.slt-rubl-doc         =  bf_tt-allsum-line.sum-dsc-rubl-doc * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.vat-base-buyer-doc   =  (bf_tt-allsum-line.sum-dsc-base-doc - bf_tt-allsum-line.slt-base-doc) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.vat-rubl-buyer-doc   =  (bf_tt-allsum-line.sum-dsc-rubl-doc - bf_tt-allsum-line.slt-rubl-doc) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.road-tax-base-doc    =  0
      bf_tt-allsum-line.road-tax-rubl-doc    =  0
      bf_tt-allsum-line.excise-base-doc      =  0
      bf_tt-allsum-line.excise-rubl-doc      =  0
      bf_tt-allsum-line.vat-base-doc         =  bf_tt-allsum-line.vat-base-buyer-doc
      bf_tt-allsum-line.vat-rubl-doc         =  bf_tt-allsum-line.vat-rubl-buyer-doc
      bf_tt-allsum-line.dsc-base-cur         =  0
      bf_tt-allsum-line.dsc-rubl-cur         =  0
      bf_tt-allsum-line.slt-base-cur         =  bf_tt-allsum-line.sum-dsc-base-cur * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.slt-rubl-cur         =  bf_tt-allsum-line.sum-dsc-rubl-cur * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.vat-base-buyer-cur   =  (bf_tt-allsum-line.sum-dsc-base-cur - bf_tt-allsum-line.slt-base-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.vat-rubl-buyer-cur   =  (bf_tt-allsum-line.sum-dsc-rubl-cur - bf_tt-allsum-line.slt-rubl-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.road-tax-base-cur    =  0
      bf_tt-allsum-line.road-tax-rubl-cur    =  0
      bf_tt-allsum-line.excise-base-cur      =  0
      bf_tt-allsum-line.excise-rubl-cur      =  0
      bf_tt-allsum-line.vat-base-cur         =  bf_tt-allsum-line.vat-base-buyer-cur
      bf_tt-allsum-line.vat-rubl-cur         =  bf_tt-allsum-line.vat-rubl-buyer-cur
      bf_tt-allsum-line.dsc-base-acc         =  0
      bf_tt-allsum-line.dsc-rubl-acc         =  0
      bf_tt-allsum-line.dsc-cli-acc          =  0
      bf_tt-allsum-line.slt-base-acc         =  0
      bf_tt-allsum-line.slt-rubl-acc         =  0
      bf_tt-allsum-line.slt-cli-acc          =  0
      bf_tt-allsum-line.road-tax-base-acc    =  0
      bf_tt-allsum-line.road-tax-rubl-acc    =  0
      bf_tt-allsum-line.road-tax-cli-acc     =  0
      bf_tt-allsum-line.excise-base-acc      =  0
      bf_tt-allsum-line.excise-rubl-acc      =  0
      bf_tt-allsum-line.excise-cli-acc       =  0
      bf_tt-allsum-line.transport-base-acc   =  0
      bf_tt-allsum-line.transport-rubl-acc   =  0
      bf_tt-allsum-line.transport-cli-acc    =  0
      bf_tt-allsum-line.other-base-acc       =  0
      bf_tt-allsum-line.other-rubl-acc       =  0
      bf_tt-allsum-line.other-cli-acc        =  0
      .
    create bfs_tt-allsum-line.
    assign
    bfs_tt-allsum-line.sum-type = 'основная_сумма_со_знаком':U.
    if bf_trn-doc.doc-type = 'инв':U or
       bf_trn-doc.doc-type = 'при':U    or
       bf_trn-doc.doc-type = 'возврат':U    then do:
       buffer-copy bf_tt-allsum-line except bf_tt-allsum-line.sum-type to bfs_tt-allsum-line.
    end.
    else do:
      assign
        bfs_tt-allsum-line.fact-qnty           =  - bf_tt-allsum-line.fact-qnty
        bfs_tt-allsum-line.cli-qnty            =  - bf_tt-allsum-line.cli-qnty
        bfs_tt-allsum-line.sum-dsc-base-doc    =  - bf_tt-allsum-line.sum-dsc-base-doc
        bfs_tt-allsum-line.sum-dsc-rubl-doc    =  - bf_tt-allsum-line.sum-dsc-rubl-doc
        bfs_tt-allsum-line.dsc-base-doc        =  - bf_tt-allsum-line.dsc-base-doc
        bfs_tt-allsum-line.dsc-rubl-doc        =  - bf_tt-allsum-line.dsc-rubl-doc
        bfs_tt-allsum-line.vat-base-doc        =  - bf_tt-allsum-line.vat-base-doc
        bfs_tt-allsum-line.vat-rubl-doc        =  - bf_tt-allsum-line.vat-rubl-doc
        bfs_tt-allsum-line.vat-base-buyer-doc  =  - bf_tt-allsum-line.vat-base-buyer-doc
        bfs_tt-allsum-line.vat-rubl-buyer-doc  =  - bf_tt-allsum-line.vat-rubl-buyer-doc
        bfs_tt-allsum-line.slt-base-doc        =  - bf_tt-allsum-line.slt-base-doc
        bfs_tt-allsum-line.slt-rubl-doc        =  - bf_tt-allsum-line.slt-rubl-doc
        bfs_tt-allsum-line.road-tax-base-doc   =  - bf_tt-allsum-line.road-tax-base-doc
        bfs_tt-allsum-line.road-tax-rubl-doc   =  - bf_tt-allsum-line.road-tax-rubl-doc
        bfs_tt-allsum-line.excise-base-doc     =  - bf_tt-allsum-line.excise-base-doc
        bfs_tt-allsum-line.excise-rubl-doc     =  - bf_tt-allsum-line.excise-rubl-doc
        bfs_tt-allsum-line.sum-dsc-base-cur    =  - bf_tt-allsum-line.sum-dsc-base-cur
        bfs_tt-allsum-line.sum-dsc-rubl-cur    =  - bf_tt-allsum-line.sum-dsc-rubl-cur
        bfs_tt-allsum-line.dsc-base-cur        =  - bf_tt-allsum-line.dsc-base-cur
        bfs_tt-allsum-line.dsc-rubl-cur        =  - bf_tt-allsum-line.dsc-rubl-cur
        bfs_tt-allsum-line.vat-base-cur        =  - bf_tt-allsum-line.vat-base-cur
        bfs_tt-allsum-line.vat-rubl-cur        =  - bf_tt-allsum-line.vat-rubl-cur
        bfs_tt-allsum-line.vat-base-buyer-cur  =  - bf_tt-allsum-line.vat-base-buyer-cur
        bfs_tt-allsum-line.vat-rubl-buyer-cur  =  - bf_tt-allsum-line.vat-rubl-buyer-cur
        bfs_tt-allsum-line.slt-base-cur        =  - bf_tt-allsum-line.slt-base-cur
        bfs_tt-allsum-line.slt-rubl-cur        =  - bf_tt-allsum-line.slt-rubl-cur
        bfs_tt-allsum-line.road-tax-base-cur   =  - bf_tt-allsum-line.road-tax-base-cur
        bfs_tt-allsum-line.road-tax-rubl-cur   =  - bf_tt-allsum-line.road-tax-rubl-cur
        bfs_tt-allsum-line.excise-base-cur     =  - bf_tt-allsum-line.excise-base-cur
        bfs_tt-allsum-line.excise-rubl-cur     =  - bf_tt-allsum-line.excise-rubl-cur
        bfs_tt-allsum-line.sum-dsc-base-acc    =  - bf_tt-allsum-line.sum-dsc-base-acc
        bfs_tt-allsum-line.sum-dsc-rubl-acc    =  - bf_tt-allsum-line.sum-dsc-rubl-acc
        bfs_tt-allsum-line.sum-dsc-cli-acc     =  - bf_tt-allsum-line.sum-dsc-cli-acc
        bfs_tt-allsum-line.dsc-base-acc        =  - bf_tt-allsum-line.dsc-base-acc
        bfs_tt-allsum-line.dsc-rubl-acc        =  - bf_tt-allsum-line.dsc-rubl-acc
        bfs_tt-allsum-line.dsc-cli-acc         =  - bf_tt-allsum-line.dsc-cli-acc
        bfs_tt-allsum-line.vat-base-acc        =  - bf_tt-allsum-line.vat-base-acc
        bfs_tt-allsum-line.vat-rubl-acc        =  - bf_tt-allsum-line.vat-rubl-acc
        bfs_tt-allsum-line.vat-cli-acc         =  - bf_tt-allsum-line.vat-cli-acc
        bfs_tt-allsum-line.slt-base-acc        =  - bf_tt-allsum-line.slt-base-acc
        bfs_tt-allsum-line.slt-rubl-acc        =  - bf_tt-allsum-line.slt-rubl-acc
        bfs_tt-allsum-line.slt-cli-acc         =  - bf_tt-allsum-line.slt-cli-acc
        bfs_tt-allsum-line.road-tax-base-acc   =  - bf_tt-allsum-line.road-tax-base-acc
        bfs_tt-allsum-line.road-tax-rubl-acc   =  - bf_tt-allsum-line.road-tax-rubl-acc
        bfs_tt-allsum-line.road-tax-cli-acc    =  - bf_tt-allsum-line.road-tax-cli-acc
        bfs_tt-allsum-line.excise-base-acc     =  - bf_tt-allsum-line.excise-base-acc
        bfs_tt-allsum-line.excise-rubl-acc     =  - bf_tt-allsum-line.excise-rubl-acc
        bfs_tt-allsum-line.excise-cli-acc      =  - bf_tt-allsum-line.excise-cli-acc
        bfs_tt-allsum-line.transport-base-acc  =  - bf_tt-allsum-line.transport-base-acc
        bfs_tt-allsum-line.transport-rubl-acc  =  - bf_tt-allsum-line.transport-rubl-acc
        bfs_tt-allsum-line.transport-cli-acc   =  - bf_tt-allsum-line.transport-cli-acc
        bfs_tt-allsum-line.other-base-acc      =  - bf_tt-allsum-line.other-base-acc
        bfs_tt-allsum-line.other-rubl-acc      =  - bf_tt-allsum-line.other-rubl-acc
        bfs_tt-allsum-line.other-cli-acc       =  - bf_tt-allsum-line.other-cli-acc
        .
    end.
    create bfo_tt-allsum-line.
    assign
      bfo_tt-allsum-line.sum-type = 'сумма_по_услуге':U.
    buffer-copy bf_tt-allsum-line except bf_tt-allsum-line.sum-type to bfo_tt-allsum-line.
    create bfos_tt-allsum-line.
    assign
      bfos_tt-allsum-line.sum-type = 'сумма_по_услуге_со_знаком':U.
    buffer-copy bfs_tt-allsum-line except bfs_tt-allsum-line.sum-type to bfos_tt-allsum-line.
  end.
  else do:
    assign
      varlastcur-base      = 0
      varlastcur-road-tax  = 0
      varlastcur-excise    = 0
      varcur-base          = 0
      varcur-road-tax      = 0
      varcur-excise        = 0
      varcur-vat-pc        = 0
      varcur-slt-pc        = 0
      varcur-fact-qnty     = 0
    .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  ?
  ,output varb-code
  )  .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcprcex in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  varb-code
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-sale
  ,output varroad-tax
  ,output varexcise
  ,output varcur-vat-pc
  ,output varcur-slt-pc
  )  .
    if varprice-sale = ?
    then do:
      assign
        varcur-vat-pc = 0
        varcur-slt-pc = 0
      .
    end.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf_goods.gds-code
  ,input  '1':U
  ,input  bf_trn-doc.fact-date
  ,input  bf_trn-doc.host-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output varcur-vat-pc
  ) no-error .
    if varcur-vat-pc = ?
    then do:
      return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3 документ &4", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_trn-doc.doc-code).
    end.
    if varcur-slt-pc = ?
    then do:
      return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3 документ &4", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_trn-doc.doc-code).
    end.
    v-calcbypart = no.
    if bf_doc-line.whole-send-news = integer('1':U)   then
    v-calcbypart = yes.
    else do:
    for each bf_gds-dtl no-lock
      where bf_gds-dtl.doc-code  = bf_doc-line.doc-code
        and bf_gds-dtl.artic     = bf_doc-line.artic
        and bf_gds-dtl.prod-type = bf_doc-line.prod-type
        and bf_gds-dtl.prod-code = bf_doc-line.prod-code
    on error undo, return error return-value
    :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  bf_gds-dtl.prt-code
  ,output varb-code
  ) no-error .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  varb-code
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-sale
  ,output varroad-tax
  ,output varexcise
  )  .
          if varprice-sale = ?
          then do:
            assign
              varprice-sale = 0
              varroad-tax   = 0
              varexcise     = 0
            .
          end.
          assign
            varlastcur-base     = varprice-sale
            varlastcur-road-tax = varroad-tax
            varlastcur-excise   = varexcise
            varcur-base         = varcur-base      + varprice-sale * bf_gds-dtl.fact-qnty
            varcur-road-tax     = varcur-road-tax  + varroad-tax   * bf_gds-dtl.fact-qnty
            varcur-excise       = varcur-excise    + varexcise     * bf_gds-dtl.fact-qnty
            varcur-fact-qnty    = varcur-fact-qnty + bf_gds-dtl.fact-qnty
          .
      end.
    end.
    if varcur-fact-qnty = 0 then do:
      assign
        varcur-base      = varlastcur-base
        varcur-road-tax  = varlastcur-road-tax
        varcur-excise    = varlastcur-excise
      .
    end.
    else do:
      assign
        varcur-base      = varcur-base      / varcur-fact-qnty
        varcur-road-tax  = varcur-road-tax  / varcur-fact-qnty
        varcur-excise    = varcur-excise    / varcur-fact-qnty
      .
    end.
    if varcur-vat-pc = ?
    then do:
      return error substitute ("Нет текущего продажного НДС по товару &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
    end.
    if varcur-slt-pc = ?
    then do:
      return error substitute ("Нет текущего продажного НП по товару &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
    end.
    find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
    assign
      varcur-cons-vat-pc = bf_sysconf.cons-vat-pc.
    if varcur-cons-vat-pc = ? then do:
      return error substitute ("Нет текущего продажного консигнационного НДС по фирме &1", bf_trn-doc.host-code).
    end.
    define buffer buf_tt-clcparts for tt-clcparts .
    for each buf_tt-clcparts
    on error undo, return error return-value
    :
      delete buf_tt-clcparts.
    end.
    for each bf_parts no-lock
      where bf_parts.out-code  = bf_doc-line.doc-code
        and bf_parts.obj-type  = bf_doc-line.obj-type
        and bf_parts.obj-code  = bf_doc-line.obj-code
        and bf_parts.artic     = bf_doc-line.artic
        and bf_parts.prod-type = bf_doc-line.prod-type
        and bf_parts.prod-code = bf_doc-line.prod-code
    on error undo, return error return-value
    :
      create buf_tt-clcparts .
      buffer-copy bf_parts to buf_tt-clcparts .
      if v-calcbypart = yes   then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer bf_parts
  ,output v-b-pcode
  ) no-error .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  bf_parts.obj-type
  ,input  bf_parts.obj-code
  ,input  v-b-pcode
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-salef
  ,output varroad-tax
  ,output varexcise
  ) no-error .
          if varprice-sale = ?
          then do:
            assign
              varprice-salef = 0
              varroad-tax   = 0
              varexcise     = 0
            .
          end.
          assign
          part-cur-base  = varprice-salef
          part-cur-road-tax  = varroad-tax
          part-cur-excise = varexcise.
      end.
    end.
    run clcprtsl_calc-ttable in this-procedure
      (input yes,
       input yes,
       input bf_doc-line.road-tax,
       input bf_doc-line.excise,
       input bf_doc-line.vat-pc,
       input bf_doc-line.cons-vat-pc,
       input bf_doc-line.slt-pc,
       input bf_trn-doc.base-rate,
       input bf_trn-doc.base-scale,
       input varr-b,
       input varcur-base,
       input varcur-road-tax,
       input varcur-excise,
       input varcur-vat-pc,
       input varcur-cons-vat-pc,
       input varcur-slt-pc
       ) no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры clcprtsl_calc-ttable." skip
        return-value skip
        trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5)) skip
        view-as alert-box error.
      undo, return error .
    end.
  end.
end.
end.
procedure clcprtsl_calc-ttable :
define input parameter paris-doc           as   logical                 no-undo.
define input parameter paris-cur           as   logical                 no-undo.
define input parameter parroad-tax         like ub.doc-line.road-tax    no-undo.
define input parameter parexcise           like ub.doc-line.excise      no-undo.
define input parameter parvat-pc           like ub.doc-line.vat-pc      no-undo.
define input parameter parcons-vat-pc      like ub.doc-line.cons-vat-pc no-undo.
define input parameter parslt-pc           like ub.doc-line.slt-pc      no-undo.
define input parameter parbase-rate        like ub.trn-doc.base-rate    no-undo.
define input parameter parbase-scale       like ub.trn-doc.base-scale   no-undo.
define input parameter parr-b              as   character               no-undo.
define input parameter parcur-base         like ub.gds-dtl.cur-base     no-undo.
define input parameter parcur-road-tax     like ub.doc-line.road-tax    no-undo.
define input parameter parcur-excise       like ub.doc-line.excise      no-undo.
define input parameter parcur-vat-pc       like ub.doc-line.vat-pc      no-undo.
define input parameter parcurcons-vat-pc   like ub.doc-line.cons-vat-pc no-undo.
define input parameter parcurslt-pc        like ub.doc-line.slt-pc      no-undo.
define buffer bf_tt-allsum      for tt-allsum.
define buffer bf_tt-clcparts    for tt-clcparts.
define buffer bf_tt-allsum-line for tt-allsum-line.
define variable v-b-pcode          like ub.bar-code.b-code     no-undo.
define variable vardoc-num         like ub.price-doc.doc-num     no-undo.
define variable varprice-sale      like ub.price-list.price-sale no-undo.
define variable varroad-tax        like ub.price-list.road-tax   no-undo.
define variable varexcise          like ub.price-list.excise     no-undo.
do on error undo, return error return-value :
for each bf_tt-allsum-line
on error undo, return error return-value
 :
  delete bf_tt-allsum-line.
end.
for each bf_tt-allsum
on error undo, return error return-value
:
  delete bf_tt-allsum.
end.
for each bf_tt-clcparts
on error undo, return error return-value
:
if v-calcbypart then do:
          assign
          parcur-base =   bf_tt-clcparts.part-cur-base
          parcur-road-tax = bf_tt-clcparts.part-cur-road-tax
          parcur-excise =   bf_tt-clcparts.part-cur-excise
          .
end.
   run clcprtsl_calc-parts in this-procedure (
     input recid(bf_tt-clcparts),
     input paris-doc,
     input paris-cur,
     input parroad-tax,
     input parexcise,
     input parvat-pc,
     input parcons-vat-pc,
     input parslt-pc,
     input parbase-rate,
     input parbase-scale,
     input parr-b,
     input parcur-base,
     input parcur-road-tax,
     input parcur-excise,
     input parcur-vat-pc,
     input parcurcons-vat-pc,
     input parcurslt-pc
     ) no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      vss-include-info11 skip
      "Ошибка при обсчете партии" skip
      "Документ партии " bf_tt-clcparts.out-code skip
      "Товар" bf_tt-clcparts.artic bf_tt-clcparts.prod-type bf_tt-clcparts.prod-code skip
      return-value skip
      error-status:get-message(1) skip
      error-status:get-message(2) skip
      error-status:get-message(3) skip
      view-as alert-box error .
    undo, return error .
  end.
  for each bf_tt-allsum on error undo, return error return-value :
    find first bf_tt-allsum-line where bf_tt-allsum-line.sum-type = bf_tt-allsum.sum-type no-error.
    if not available bf_tt-allsum-line then do:
      create bf_tt-allsum-line.
      assign
        bf_tt-allsum-line.sum-type = bf_tt-allsum.sum-type.
    end.
    assign
      bf_tt-allsum-line.fact-qnty              = bf_tt-allsum-line.fact-qnty            + bf_tt-allsum.fact-qnty
      bf_tt-allsum-line.cli-qnty               = bf_tt-allsum-line.cli-qnty             + bf_tt-allsum.cli-qnty
      bf_tt-allsum-line.sum-dsc-base-doc       = bf_tt-allsum-line.sum-dsc-base-doc     + bf_tt-allsum.sum-dsc-base-doc
      bf_tt-allsum-line.sum-dsc-rubl-doc       = bf_tt-allsum-line.sum-dsc-rubl-doc     + bf_tt-allsum.sum-dsc-rubl-doc
      bf_tt-allsum-line.dsc-base-doc           = bf_tt-allsum-line.dsc-base-doc         + bf_tt-allsum.dsc-base-doc
      bf_tt-allsum-line.dsc-rubl-doc           = bf_tt-allsum-line.dsc-rubl-doc         + bf_tt-allsum.dsc-rubl-doc
      bf_tt-allsum-line.vat-base-doc           = bf_tt-allsum-line.vat-base-doc         + bf_tt-allsum.vat-base-doc
      bf_tt-allsum-line.vat-rubl-doc           = bf_tt-allsum-line.vat-rubl-doc         + bf_tt-allsum.vat-rubl-doc
      bf_tt-allsum-line.vat-base-buyer-doc     = bf_tt-allsum-line.vat-base-buyer-doc   + bf_tt-allsum.vat-base-buyer-doc
      bf_tt-allsum-line.vat-rubl-buyer-doc     = bf_tt-allsum-line.vat-rubl-buyer-doc   + bf_tt-allsum.vat-rubl-buyer-doc
      bf_tt-allsum-line.slt-base-doc           = bf_tt-allsum-line.slt-base-doc         + bf_tt-allsum.slt-base-doc
      bf_tt-allsum-line.slt-rubl-doc           = bf_tt-allsum-line.slt-rubl-doc         + bf_tt-allsum.slt-rubl-doc
      bf_tt-allsum-line.road-tax-base-doc      = bf_tt-allsum-line.road-tax-base-doc    + bf_tt-allsum.road-tax-base-doc
      bf_tt-allsum-line.road-tax-rubl-doc      = bf_tt-allsum-line.road-tax-rubl-doc    + bf_tt-allsum.road-tax-rubl-doc
      bf_tt-allsum-line.excise-base-doc        = bf_tt-allsum-line.excise-base-doc      + bf_tt-allsum.excise-base-doc
      bf_tt-allsum-line.excise-rubl-doc        = bf_tt-allsum-line.excise-rubl-doc      + bf_tt-allsum.excise-rubl-doc
      bf_tt-allsum-line.sum-dsc-base-cur       = bf_tt-allsum-line.sum-dsc-base-cur     + bf_tt-allsum.sum-dsc-base-cur
      bf_tt-allsum-line.sum-dsc-rubl-cur       = bf_tt-allsum-line.sum-dsc-rubl-cur     + bf_tt-allsum.sum-dsc-rubl-cur
      bf_tt-allsum-line.dsc-base-cur           = bf_tt-allsum-line.dsc-base-cur         + bf_tt-allsum.dsc-base-cur
      bf_tt-allsum-line.dsc-rubl-cur           = bf_tt-allsum-line.dsc-rubl-cur         + bf_tt-allsum.dsc-rubl-cur
      bf_tt-allsum-line.vat-base-cur           = bf_tt-allsum-line.vat-base-cur         + bf_tt-allsum.vat-base-cur
      bf_tt-allsum-line.vat-rubl-cur           = bf_tt-allsum-line.vat-rubl-cur         + bf_tt-allsum.vat-rubl-cur
      bf_tt-allsum-line.vat-base-buyer-cur     = bf_tt-allsum-line.vat-base-buyer-cur   + bf_tt-allsum.vat-base-buyer-cur
      bf_tt-allsum-line.vat-rubl-buyer-cur     = bf_tt-allsum-line.vat-rubl-buyer-cur   + bf_tt-allsum.vat-rubl-buyer-cur
      bf_tt-allsum-line.slt-base-cur           = bf_tt-allsum-line.slt-base-cur         + bf_tt-allsum.slt-base-cur
      bf_tt-allsum-line.slt-rubl-cur           = bf_tt-allsum-line.slt-rubl-cur         + bf_tt-allsum.slt-rubl-cur
      bf_tt-allsum-line.road-tax-base-cur      = bf_tt-allsum-line.road-tax-base-cur    + bf_tt-allsum.road-tax-base-cur
      bf_tt-allsum-line.road-tax-rubl-cur      = bf_tt-allsum-line.road-tax-rubl-cur    + bf_tt-allsum.road-tax-rubl-cur
      bf_tt-allsum-line.excise-base-cur        = bf_tt-allsum-line.excise-base-cur      + bf_tt-allsum.excise-base-cur
      bf_tt-allsum-line.excise-rubl-cur        = bf_tt-allsum-line.excise-rubl-cur      + bf_tt-allsum.excise-rubl-cur
      bf_tt-allsum-line.sum-dsc-base-acc       = bf_tt-allsum-line.sum-dsc-base-acc     + bf_tt-allsum.sum-dsc-base-acc
      bf_tt-allsum-line.sum-dsc-rubl-acc       = bf_tt-allsum-line.sum-dsc-rubl-acc     + bf_tt-allsum.sum-dsc-rubl-acc
      bf_tt-allsum-line.sum-dsc-cli-acc        = bf_tt-allsum-line.sum-dsc-cli-acc      + bf_tt-allsum.sum-dsc-cli-acc
      bf_tt-allsum-line.dsc-base-acc           = bf_tt-allsum-line.dsc-base-acc         + bf_tt-allsum.dsc-base-acc
      bf_tt-allsum-line.dsc-rubl-acc           = bf_tt-allsum-line.dsc-rubl-acc         + bf_tt-allsum.dsc-rubl-acc
      bf_tt-allsum-line.dsc-cli-acc            = bf_tt-allsum-line.dsc-cli-acc          + bf_tt-allsum.dsc-cli-acc
      bf_tt-allsum-line.vat-base-acc           = bf_tt-allsum-line.vat-base-acc         + bf_tt-allsum.vat-base-acc
      bf_tt-allsum-line.vat-rubl-acc           = bf_tt-allsum-line.vat-rubl-acc         + bf_tt-allsum.vat-rubl-acc
      bf_tt-allsum-line.vat-cli-acc            = bf_tt-allsum-line.vat-cli-acc          + bf_tt-allsum.vat-cli-acc
      bf_tt-allsum-line.slt-base-acc           = bf_tt-allsum-line.slt-base-acc         + bf_tt-allsum.slt-base-acc
      bf_tt-allsum-line.slt-rubl-acc           = bf_tt-allsum-line.slt-rubl-acc         + bf_tt-allsum.slt-rubl-acc
      bf_tt-allsum-line.slt-cli-acc            = bf_tt-allsum-line.slt-cli-acc          + bf_tt-allsum.slt-cli-acc
      bf_tt-allsum-line.road-tax-base-acc      = bf_tt-allsum-line.road-tax-base-acc    + bf_tt-allsum.road-tax-base-acc
      bf_tt-allsum-line.road-tax-rubl-acc      = bf_tt-allsum-line.road-tax-rubl-acc    + bf_tt-allsum.road-tax-rubl-acc
      bf_tt-allsum-line.road-tax-cli-acc       = bf_tt-allsum-line.road-tax-cli-acc     + bf_tt-allsum.road-tax-cli-acc
      bf_tt-allsum-line.excise-base-acc        = bf_tt-allsum-line.excise-base-acc      + bf_tt-allsum.excise-base-acc
      bf_tt-allsum-line.excise-rubl-acc        = bf_tt-allsum-line.excise-rubl-acc      + bf_tt-allsum.excise-rubl-acc
      bf_tt-allsum-line.excise-cli-acc         = bf_tt-allsum-line.excise-cli-acc       + bf_tt-allsum.excise-cli-acc
      bf_tt-allsum-line.transport-base-acc     = bf_tt-allsum-line.transport-base-acc   + bf_tt-allsum.transport-base-acc
      bf_tt-allsum-line.transport-rubl-acc     = bf_tt-allsum-line.transport-rubl-acc   + bf_tt-allsum.transport-rubl-acc
      bf_tt-allsum-line.transport-cli-acc      = bf_tt-allsum-line.transport-cli-acc    + bf_tt-allsum.transport-cli-acc
      bf_tt-allsum-line.other-base-acc         = bf_tt-allsum-line.other-base-acc       + bf_tt-allsum.other-base-acc
      bf_tt-allsum-line.other-rubl-acc         = bf_tt-allsum-line.other-rubl-acc       + bf_tt-allsum.other-rubl-acc
      bf_tt-allsum-line.other-cli-acc          = bf_tt-allsum-line.other-cli-acc        + bf_tt-allsum.other-cli-acc
      .
  end.
end.
end.
end procedure.
define temp-table tt-doc-line-sum     no-undo like ub.doc-line-sum.
define temp-table tt-old-doc-line-sum no-undo like tt-doc-line-sum.
define temp-table tt-wast-line        no-undo
  field obj-type            like ub.doc-line.obj-type
  field obj-code            like ub.doc-line.obj-code
  field status_             like ub.doc-line.status_
  field artic               like ub.doc-line.artic
  field prod-type           like ub.doc-line.prod-type
  field prod-code           like ub.doc-line.prod-code
  field fact-order          like ub.doc-line.fact-order
  field prev-inv-fact-order like ub.doc-line.fact-order
  index prev-inv-fact-order      prev-inv-fact-order.
  define new global shared variable g#lib-rwds as handle no-undo.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxp-doc-prt         like ub.store.doc-prt         no-undo.
  define variable v-cntxp-price-calc      like ub.store.price-calc      no-undo.
  define variable v-cntxp-inout-price     like ub.store.inout-price     no-undo.
  define variable v-cntxp-unit-cli-perm   like ub.store.unit-cli-perm   no-undo.
  define variable v-cntxp-out-rate        like ub.store.out-rate        no-undo.
  define variable v-cntxp-out-line-discnt like ub.store.out-line-discnt no-undo.
  define variable v-cntxp-in-ov           like ub.store.in-ov           no-undo.
  define variable v-cntxp-in-perm         like ub.store.in-perm         no-undo.
  define variable v-cntxp-no-eq           like ub.store.no-eq           no-undo.
  define variable v-cntxp-rsrv-time       like ub.store.rsrv-time       no-undo.
  define variable v-cntxp-load-time       like ub.store.load-time       no-undo.
  define variable v-cntxp-holidays        like ub.store.holidays        no-undo.
  define variable v-cntxp-in-pay          like ub.store.in-pay          no-undo.
  define variable v-cntxp-out-pay         like ub.store.out-pay         no-undo.
  define variable v-cntxp-ret-pay         like ub.store.ret-pay         no-undo.
  define variable v-cntxp-ret-sup-pay     like ub.store.ret-sup-pay     no-undo.
  define variable v-cntxp-down-pay        like ub.store.down-pay        no-undo.
  define variable v-cntxp-inv-pay         like ub.store.inv-pay         no-undo.
  define variable v-cntxp-chk-pay         like ub.store.chk-pay         no-undo.
  define variable v-cntxp-retail          like ub.sysconf.ord-prt       no-undo.
  define variable v-cntxp-osn-base        like ub.sysconf.osn-base      no-undo.
  define variable v-cntxp-conf-par        as   character                no-undo.
  define variable v-cntxp-par-type        as   character                no-undo.
  define variable v-cntxp-curr-host-code  like ub.store.host-code       no-undo.
  define variable v-cntxp-obj-type        like ub.clients.obj-type      no-undo.
  define variable v-cntxp-obj-code        like ub.clients.obj-code      no-undo.
  define variable v-cntxp-db-num          as integer   no-undo .
  define variable v-cntxp-userid          as character no-undo .
  define variable v-cntxp-level           as character no-undo .
  define variable v-cntxp-db-num-obj      as integer   no-undo .
  define variable v-cntxp-is-admin        as logical   no-undo .
  define buffer bf-cntxp_store for ub.store.
  define buffer bf-cntxp_shop  for ub.shop.
  define buffer bf-cntxp_sysconf for ub.sysconf.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxp-db-num
    ,output v-cntxp-userid
    ,output v-cntxp-level
    ,output v-cntxp-curr-host-code
    ,output v-cntxp-obj-type
    ,output v-cntxp-obj-code
    ,output v-cntxp-db-num-obj
    ,output v-cntxp-is-admin
    ) .
  if (v-cntxp-obj-type = 'маг':U or v-cntxp-obj-type = 'скл':U) and
     v-cntxp-obj-code <> 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output v-cntxp-conf-par
  ,output v-cntxp-par-type
  ) no-error .
    case v-cntxp-obj-type :
      when 'скл':U then do:
        find first bf-cntxp_store where bf-cntxp_store.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_store.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_store.doc-prt
          v-cntxp-price-calc      = bf-cntxp_store.price-calc
          v-cntxp-inout-price     = bf-cntxp_store.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_store.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_store.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_store.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_store.in-ov
          v-cntxp-in-perm         = bf-cntxp_store.in-perm
          v-cntxp-no-eq           = bf-cntxp_store.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_store.rsrv-time
          v-cntxp-load-time       = bf-cntxp_store.load-time
          v-cntxp-holidays        = bf-cntxp_store.holidays
          v-cntxp-in-pay          = bf-cntxp_store.in-pay
          v-cntxp-out-pay         = bf-cntxp_store.out-pay
          v-cntxp-ret-pay         = bf-cntxp_store.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_store.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_store.down-pay
          v-cntxp-inv-pay         = bf-cntxp_store.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_store.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
      when 'маг':U then do:
        find first bf-cntxp_shop where bf-cntxp_shop.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_shop.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_shop.doc-prt
          v-cntxp-price-calc      = bf-cntxp_shop.price-calc
          v-cntxp-inout-price     = bf-cntxp_shop.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_shop.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_shop.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_shop.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_shop.in-ov
          v-cntxp-in-perm         = bf-cntxp_shop.in-perm
          v-cntxp-no-eq           = bf-cntxp_shop.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_shop.rsrv-time
          v-cntxp-load-time       = bf-cntxp_shop.load-time
          v-cntxp-holidays        = bf-cntxp_shop.holidays
          v-cntxp-in-pay          = bf-cntxp_shop.in-pay
          v-cntxp-out-pay         = bf-cntxp_shop.out-pay
          v-cntxp-ret-pay         = bf-cntxp_shop.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_shop.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_shop.down-pay
          v-cntxp-inv-pay         = bf-cntxp_shop.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_shop.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
    end case.
  end.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info31, return-value, chr(10), error-status :get-message (1)).
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info31, return-value, chr(10), error-status :get-message (1)).
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
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define temp-table tt-utd like ub.utd
  field stts        as character
  field stts-edi    as character
  field cli-name    as character
  field EDoTypeName as character
  field ModifyTime_ as character
  field orig-code   as character
  field GrayZone    as logical
  field obj-name    as character
  field is-initial  as character
  field scan-qnty   as decimal
  field free-qnty   as decimal
  .
define temp-table tt-sert-utd
  field doc-id like ub.utd.doc-id
  field db-num like ub.utd.db-num
  field DocumentDate like ub.utd.DocumentDate
  field DocumentNumber like ub.utd.DocumentNumber
  field cli-code as integer
  field cli-type as character
  index pi  db-num doc-id
  .
define temp-table tt-utd-lines-filtr no-undo
    field db-num  as integer
    field doc-id  as integer
    field linenum as integer
    field bar-code as character
    index pi  db-num doc-id LineNum
    index bar-code bar-code db-num doc-id LineNum
.
define temp-table tt-utd-lines like ub.utd-lines
  field qnty-scan as decimal
  field qnty-mark as integer
  field stts      as character
  field gds-name  as character
  field TaxRate_  as character
  field fact-qnty as decimal
  field free-qnty as decimal
  field sts_err   as logical
  field DelivCodeMis   as logical
  field UnitCli   as character
  field UnitCliQnty as decimal
  field isMarking   as logical
  field isArtic     as logical
  field isWeight    as logical
  field isVarWeight as logical
  field isSelect    as logical
  field markType    as character
  field PieceTTH    as character
  field PieceFact   as character
  index pi  db-num doc-id LineNum
  index gds-code gds-code
  index sts stts sts
  .
define temp-table tt-marking-lines no-undo like ub.marking-lines
  field mark-parent like ub.marking.mark-parent
  field stts        as character
  field sts-utd     as integer
  field stts-utd    as character
  field unit        as character
  field unit-ext    as character
  field site        as character
  field box-qnty    as decimal
  field gds-name    as character
  field db-num      as integer
  field doc-id      as integer
  field LineNum     as integer
  field GrayZone    as logical
  field isMark      as logical
  field isWeight    as logical
  field marking-string as character
  field old-sts     as integer
  field weight      as character
  index pi  doc-level   sts
  index pi2 mark-parent sts
  index pi3 unit-ext
  index pi4 mark obj-type obj-code gds-code in-code out-code part-code prt-code
  index part gds-code obj-type obj-code in-code out-code part-code prt-code
  index gds-code gds-code
  index obj obj-code obj-type
  .
define temp-table tt-mark-line like ub.marking-lines
  field date_    as date
  field doc-type as character
  field type     as integer
  field doc-id   as integer
  field db-num   as integer
  field EdocType as integer
  index pi mark out-code doc-type .
define temp-table tt-marking like ub.marking
  .
define temp-table tt-utd-marking-lines like ub.utd-marking-lines
  .
define temp-table tt-inv-marking no-undo
  field gds-code      as integer
  field gds-name      as character
  field qnty          as decimal
  field qnty-scan     as decimal
  field qnty-confirm  as integer
  field qnty-scan-not as integer
  field qnty-not      as integer
  index pi gds-code
  .
define temp-table tt-tech-mark no-undo
  field gds-code      as integer
  field gds-name      as character
  field qnty-fact     as integer
  field qnty-doc      as integer
  field doc-code      as character
  field line-num      as integer
  index pi as UNIQUE doc-code line-num gds-code
  .
define temp-table tt-utd-err like ub.utd-err
  field descr as character
  field gds-code as integer
  field LineNum  as integer
  field type     as integer
  .
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-upd-attr no-undo
  field code           as character
  field type-attr      as character
  field format-attr    as character
  field fillin_width   as integer
  field fillin_height  as integer
  field label-attr     as character
  field user-can-edit  as logical
  field output-display as logical
  field hot-key        as character
  field can-select     as logical
  field other          as character
  field proc-attr      as character
  field proc-win       as character
  field proc-func      as character
  field full-screen-val as character
  field sort_       as integer
  index code is primary unique code
  index output-display output-display code
  index by-sort sort_
  .
define temp-table tt-upd-attr-fuel no-undo
  field code           as character
  field type-attr      as character
  field format-attr    as character
  field fillin_width   as integer
  field fillin_height  as integer
  field label-attr     as character
  field user-can-edit  as logical
  field output-display as logical
  field hot-key        as character
  field can-select     as logical
  field other          as character
  field proc-attr      as character
  field proc-win       as character
  field proc-func      as character
  field full-screen-val as character
  field sort_       as integer
  index code is primary unique code
  index output-display output-display code
  index by-sort sort_
  .
define temp-table tt-gds-list no-undo like ub.goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.
define buffer t-doc      for ub.trn-doc.
define buffer cli-buf    for ub.clients.
define buffer l-doc-line for ub.doc-line.
define buffer bf_sysconf for ub.sysconf.
define buffer clients for ub.clients  .
define buffer bf_rvs for ub.rvs-doc  .
define buffer bf_rvs-l-attr for ub.rvs-line-attr  .
define buffer bf_rvs-line for ub.rvs-line  .
define buffer db for ub.db  .
define rectangle rect-trn-doc size 68.5 by 2.5 EDGE-PIXELS 2 GRAPHIC-EDGE bgcolor 8.
define rectangle rect-inv-doc size 47.0 by 4.2 EDGE-PIXELS 2 GRAPHIC-EDGE bgcolor 8.
define rectangle rect-tog     size 21.5 by 4.2 EDGE-PIXELS 2 GRAPHIC-EDGE bgcolor 8.
define variable v-inv-prsr                          as character no-undo .
define variable v-long-char as longchar no-undo .
define variable ref-list                            as   character                     no-undo.
define variable unrv-qnty                           as   decimal                       no-undo.
define variable is-cdinv                            as   character                     no-undo .
define variable vartot-docold                       like ub.trn-doc.tot-doc            no-undo.
define variable vartot-rublold                      like ub.trn-doc.tot-rubl           no-undo.
define variable i-total-doc-line_tot-ovold          like ub.trn-doc.tot-ov             no-undo.
define variable i-total-doc-line_fact-rublold       like ub.trn-doc.fact-rubl          no-undo.
define variable i-total-doc-line_fact-baseold       like ub.trn-doc.fact-base          no-undo.
define variable i-total-doc-line_fact-qntyold       like ub.trn-doc.fact-qnty          no-undo.
define variable i-total-doc-line_doc-qntyold        like ub.trn-doc.doc-qnty           no-undo.
define variable i-total-doc-line_cli-qntyold        like ub.trn-doc.cli-qnty           no-undo.
define variable i-total-parts_fact-baseold          as   decimal                       no-undo.
define variable i-total-parts_fact-rublold          as   decimal                       no-undo.
define variable i-total-parts_fact-qntyold          as   decimal                       no-undo.
define variable varinvclcwtol                       as   logical label "Естественная убыль"
                                                    view-as toggle-box size 20.5 by .77 fgcolor 4 no-undo.
define variable varinvclcasol                       as   logical label "Основные суммы"
                                                    view-as toggle-box size 20.5 by .77 fgcolor 4 no-undo.
define variable varinvclcwt                         as   logical                       no-undo.
define variable varinvclcas                         as   logical                       no-undo.
define variable varinvclcex                         as   logical                       no-undo.
define variable varinvclcms                         as   logical                       no-undo.
define variable varinvclcbef                        as   logical                       no-undo.
define variable varbefore-qnty                      like ub.doc-line.fact-qnty        no-undo.
define variable varwas-qnty-kg                      like ub.doc-line.fact-qnty        no-undo.
define variable varare-qnty-kg                      like ub.doc-line.fact-qnty        no-undo.
define variable vardiff-qnty-kg                     like ub.doc-line.fact-qnty        no-undo.
define variable varextra-qnty                       like ub.doc-line.fact-qnty        no-undo.
define variable varmiss-qnty                        like ub.doc-line.fact-qnty        no-undo.
define variable varbefore-base                      like ub.doc-line.fact-qnty        no-undo.
define variable varbefore-rubl                      like ub.doc-line.fact-qnty        no-undo.
define variable varafter-base                       like ub.doc-line.fact-qnty        no-undo.
define variable varafter-rubl                       like ub.doc-line.fact-qnty        no-undo.
define variable varextra-base                       like ub.doc-line.fact-qnty        no-undo.
define variable varextra-rubl                       like ub.doc-line.fact-qnty        no-undo.
define variable varmiss-base                        like ub.doc-line.fact-qnty        no-undo.
define variable varmiss-rubl                        like ub.doc-line.fact-qnty        no-undo.
define variable varbefore-rb                        like ub.doc-line.fact-qnty        no-undo.
define variable varafter-rb                         like ub.doc-line.fact-qnty        no-undo.
define variable varextra-rb                         like ub.doc-line.fact-qnty        no-undo.
define variable varmiss-rb                          like ub.doc-line.fact-qnty        no-undo.
define variable varwast-rb                          like ub.doc-line.price-base       no-undo.
define variable varunus-wast-rb                     like ub.doc-line.price-base       no-undo.
define variable vdoc-qnty                           as character no-undo.
define variable varr-b                              as   character                     no-undo.
define variable varmiss-without-wast                like ub.doc-line.price-base       no-undo.
define variable varwastage                          like ub.doc-line.price-base       no-undo.
define variable vardocextra-qnty                    like ub.trn-doc.fact-qnty          no-undo.
define variable vardocextra-base                    like ub.trn-doc.tot-rubl           no-undo.
define variable vardocextra-rubl                    like ub.trn-doc.tot-rubl           no-undo.
define variable vardocextra-rb                      like ub.trn-doc.tot-rubl           no-undo.
define variable vardocmiss-qnty                     like ub.trn-doc.fact-qnty          no-undo.
define variable vardocmiss-base                     like ub.trn-doc.tot-rubl           no-undo.
define variable vardocmiss-rubl                     like ub.trn-doc.tot-rubl           no-undo.
define variable vardocmiss-rb                       like ub.trn-doc.tot-rubl           no-undo.
define variable vardocwast-rb                       like ub.trn-doc.tot-rubl           no-undo.
define variable var-qnty-mark                       as   integer                       no-undo.
define variable var-qnty-mark-chk                   as   integer                       no-undo.
define variable var-qnty-mark-tech                  as   integer                       no-undo.
define variable varinvclcspvalue                    as   character                     no-undo.
define variable varinvclcsptype                     as   character                     no-undo.
define variable prtvalue                            as   character                     no-undo.
define variable varcount                            as   integer                       no-undo.
define variable vartime                             as   integer                       no-undo.
define variable prt-rec                             as   recid                         no-undo.
define variable ref-rec                             as   recid                         no-undo.
define variable varlog                              as   logical                       no-undo.
define variable lns-cnt                             as   integer                       no-undo.
define variable line-mode                           as   character                     no-undo.
define variable varvalue                            as   character                     no-undo.
define variable gds-rec                             as   recid                         no-undo.
define variable v-is-ptrl                           as   character                     no-undo.
define variable v-data-type                         as   character                     no-undo.
define variable parext-doc-mode                     as   character                     no-undo.
define variable chk-doc-option                      as   character                     no-undo.
define variable v-handl-tt                          as   handle                        no-undo.
define variable is-petrol                           as   logical                       no-undo.
define variable is-pieces                           as   logical                       no-undo.
define variable v-marking-type                      as   character                     no-undo.
define variable v-type                              as   character                     no-undo.
define variable v-is-marking                        as   logical                       no-undo init false.
define variable v-is-introduce                      as   logical                       no-undo init false.
define variable bcol                                as   handle                        extent no-undo.
define variable hBrowse                             as   handle                        no-undo.
define variable ii                                  as   integer                       no-undo.
define variable v-other                     as   character                     no-undo.
define variable ItogInv as logical no-undo .
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
DEFINE VARIABLE f-acc as decimal format "->>>,>>>,>>9.999":U
     LABEL "Погр. изм., кг "
     VIEW-AS FILL-IN
     SIZE 17 BY 1
     fgcolor 4
     NO-UNDO.
DEFINE VARIABLE f-acc-2 as decimal format "->>>,>>>,>>9.999":U
     VIEW-AS FILL-IN
     SIZE 17 BY 1
     fgcolor 4
     NO-UNDO.
DEFINE VARIABLE f-izlnedos as decimal format "->>>,>>>,>>9.999":U
     LABEL "Недостача, кг  "
     VIEW-AS FILL-IN
     SIZE 17 BY 1
     fgcolor 4
     NO-UNDO.
DEFINE VARIABLE f-izlnedos-2 as decimal format "->>>,>>>,>>9.999":U
     VIEW-AS FILL-IN
     SIZE 18 BY 1
     fgcolor 4
     NO-UNDO.
DEFINE VARIABLE f-izlheader as character init "Излишек /     " format "x(20)"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE f-meu as character init "Масса ЕУ, кг :" format "x(20)"
     VIEW-AS FILL-IN
     SIZE 20 BY 1
     NO-UNDO.
DEFINE VARIABLE f-meu-2 as decimal format "->>>,>>>,>>9.999":U
     VIEW-AS FILL-IN
     SIZE 17 BY 1
     fgcolor 4
     NO-UNDO.
DEFINE VARIABLE f-mnorml as character init "Масса ТП, кг :" format "x(20)"
     VIEW-AS FILL-IN
     SIZE 20 BY 1
     NO-UNDO.
DEFINE VARIABLE f-mnorml-2 as decimal format "->>>,>>>,>>9.999":U
     VIEW-AS FILL-IN
     SIZE 17 BY 1
     fgcolor 4
     NO-UNDO.
DEFINE VARIABLE f-notbal as decimal format "->>>,>>>,>>9.999":U
     LABEL "Небаланс, кг   "
     VIEW-AS FILL-IN
     SIZE 17 BY 1
     fgcolor 4
     NO-UNDO.
DEFINE VARIABLE f-notbal-2 as decimal format "->>>,>>>,>>9.999":U
     VIEW-AS FILL-IN
     SIZE 17 BY 1
     fgcolor 4
     NO-UNDO.
function fncgele returns character ( buffer local-doc-line for ub.doc-line ) :
  if local-doc-line.prt-OK = ? then do:
    return ''.
  end.
  else do:
    if local-doc-line.fact-qnty < 0 then do:
      return '<'.
    end.
    else do:
      if local-doc-line.fact-qnty = 0 then do:
        return '='.
      end.
      else do:
        return '>'.
      end.
    end.
  end.
end function.
function fncextra-qnty returns decimal ( buffer local-doc-line for ub.doc-line ) :
  if local-doc-line.fact-qnty > 0 then do:
    return local-doc-line.fact-qnty.
  end.
  else do:
    return 0.00.
  end.
end function.
function deviation-fact    return decimal (buffer local-rvs-line for ub.rvs-line ).
   return (local-rvs-line.state-measure-qnty   + local-rvs-line.state-add-qnty - local-rvs-line.system-qnty).
end function.
function fncmiss-qnty returns decimal ( buffer local-doc-line for ub.doc-line ) :
  if local-doc-line.fact-qnty < 0 then do:
    return - local-doc-line.fact-qnty.
  end.
  else do:
    return 0.00.
  end.
end function.
function fncbefore-base returns decimal ( buffer local-doc-line for ub.doc-line,
                                          buffer local-goods for ub.goods ) :
  define variable varreturn as decimal no-undo.
  define buffer bf_doc-line-sum for ub.doc-line-sum.
  if varinvclcbef = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = 'bd':U.
    assign
      varreturn = bf_doc-line-sum.cost-sum-base
    .
  end.
  else do:
    assign
      varreturn = ?
    .
  end.
  return varreturn.
end function.
function fncbefore-rubl returns decimal ( buffer local-doc-line for ub.doc-line,
                                          buffer local-goods for ub.goods ) :
  define variable varreturn as decimal no-undo.
  define buffer bf_doc-line-sum for ub.doc-line-sum.
  if varinvclcbef = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = 'bd':U.
    assign
      varreturn = bf_doc-line-sum.cost-sum-rubl
    .
  end.
  else do:
    assign
      varreturn = ?
    .
  end.
  return varreturn.
end function.
function fncafter-base returns decimal ( buffer local-doc-line for ub.doc-line,
                                         buffer local-goods for ub.goods ) :
  define buffer bf_doc-line-sum for ub.doc-line-sum.
  if varinvclcas = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = 'ad':U.
    return bf_doc-line-sum.cost-sum-base.
  end.
  else do:
    return ?.
  end.
end function.
function fncafter-rubl returns decimal ( buffer local-doc-line for ub.doc-line,
                                         buffer local-goods for ub.goods ) :
  define buffer bf_doc-line-sum for ub.doc-line-sum.
  if varinvclcas = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = 'ad':U.
    return bf_doc-line-sum.cost-sum-rubl.
  end.
  else do:
    return ?.
  end.
end function.
function fncextra-base returns decimal ( buffer local-doc-line for ub.doc-line,
                                         buffer local-goods for ub.goods ) :
  define buffer bf_doc-line-sum for ub.doc-line-sum.
  if varinvclcas = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = 'gen':U.
    if bf_doc-line-sum.cost-sum-base > 0 then do:
      return bf_doc-line-sum.cost-sum-base.
    end.
    else do:
      return 0.00.
    end.
  end.
  else do:
    return ?.
  end.
end function.
function fncextra-rubl returns decimal ( buffer local-doc-line for ub.doc-line,
                                         buffer local-goods for ub.goods ) :
  define buffer bf_doc-line-sum for ub.doc-line-sum.
  if varinvclcas = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = 'gen':U.
    if bf_doc-line-sum.cost-sum-rubl > 0 then do:
      return bf_doc-line-sum.cost-sum-rubl.
    end.
    else do:
      return 0.00.
    end.
  end.
  else do:
    return ?.
  end.
end function.
function fncmiss-base returns decimal ( buffer local-doc-line for ub.doc-line,
                                        buffer local-goods for ub.goods ) :
  define buffer bf_doc-line-sum for ub.doc-line-sum.
  if varinvclcas = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = 'gen':U.
    if bf_doc-line-sum.cost-sum-base < 0 then do:
      return - bf_doc-line-sum.cost-sum-base.
    end.
    else do:
      return 0.00.
    end.
  end.
  else do:
    return ?.
  end.
end function.
function fncmiss-rubl returns decimal ( buffer local-doc-line for ub.doc-line,
                                        buffer local-goods for ub.goods ) :
  define buffer bf_doc-line-sum for ub.doc-line-sum.
  if varinvclcas = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = 'gen':U.
    if bf_doc-line-sum.cost-sum-rubl < 0 then do:
      return - bf_doc-line-sum.cost-sum-rubl.
    end.
    else do:
      return 0.00.
    end.
  end.
  else do:
    return ?.
  end.
end function.
function fncbefore-rb returns decimal ( buffer local-doc-line for ub.doc-line,
                                        buffer local-goods for ub.goods ) :
  define buffer bf_doc-line-sum for ub.doc-line-sum.
  if varinvclcbef = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = 'bd':U         no-error.
    if varr-b = "base":U then do:
      return bf_doc-line-sum.crsa-sum-base.
    end.
    else do:
      return bf_doc-line-sum.crsa-sum-rubl.
    end.
  end.
  else do:
    return ?.
  end.
end function.
function fncafter-rb returns decimal ( buffer local-doc-line for ub.doc-line,
                                       buffer local-goods for ub.goods ) :
  define buffer bf-aft_doc-line-sum for ub.doc-line-sum.
  define buffer bf-bef_doc-line-sum for ub.doc-line-sum.
  define buffer bf-gen_doc-line-sum for ub.doc-line-sum.
  define buffer bf_trn-doc          for ub.trn-doc.
  if varinvclcas = yes then do:
    find first bf_trn-doc no-lock where bf_trn-doc.doc-code = local-doc-line.doc-code.
    if bf_trn-doc.status_ = 'факт':U then do:
      find first bf-aft_doc-line-sum no-lock where
                 bf-aft_doc-line-sum.doc-code = local-doc-line.doc-code and
                 bf-aft_doc-line-sum.gds-code = local-goods.gds-code and
                 bf-aft_doc-line-sum.sum-type = 'ad':U.
      if varr-b = "base" then do:
        return bf-aft_doc-line-sum.crsa-sum-base.
      end.
      else do:
        return bf-aft_doc-line-sum.crsa-sum-rubl.
      end.
    end.
    else do:
      find first bf-bef_doc-line-sum no-lock where
                 bf-bef_doc-line-sum.doc-code = local-doc-line.doc-code and
                 bf-bef_doc-line-sum.gds-code = local-goods.gds-code and
                 bf-bef_doc-line-sum.sum-type = 'bd':U.
      find first bf-gen_doc-line-sum no-lock where
                 bf-gen_doc-line-sum.doc-code = local-doc-line.doc-code and
                 bf-gen_doc-line-sum.gds-code = local-goods.gds-code and
                 bf-gen_doc-line-sum.sum-type = 'gen':U.
      if varr-b = "base" then do:
        return bf-bef_doc-line-sum.crsa-sum-base + bf-gen_doc-line-sum.sale-sum-base.
      end.
      else do:
        return bf-bef_doc-line-sum.crsa-sum-rubl + bf-gen_doc-line-sum.sale-sum-rubl.
      end.
    end.
  end.
  else do:
    return ?.
  end.
end function.
function fncextra-rb returns decimal ( buffer local-doc-line for ub.doc-line,
                                       buffer local-goods for ub.goods ) :
  define buffer bf_doc-line-sum for ub.doc-line-sum.
  if varinvclcas = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = 'gen':U.
    if varr-b = "base" then do:
      if bf_doc-line-sum.sale-sum-base > 0 then do:
        return bf_doc-line-sum.sale-sum-base.
      end.
      else do:
        return 0.00.
      end.
    end.
    else do:
      if bf_doc-line-sum.sale-sum-rubl > 0 then do:
        return bf_doc-line-sum.sale-sum-rubl.
      end.
      else do:
        return 0.00.
      end.
    end.
  end.
  else do:
    return ?.
  end.
end function.
function fncmiss-rb returns decimal ( buffer local-doc-line for ub.doc-line,
                                      buffer local-goods for ub.goods ) :
  define buffer bf_doc-line-sum for ub.doc-line-sum.
  if varinvclcas = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = 'gen':U.
    if varr-b = "base" then do:
      if bf_doc-line-sum.sale-sum-base < 0 then do:
        return - bf_doc-line-sum.sale-sum-base.
      end.
      else do:
        return 0.00.
      end.
    end.
    else do:
      if bf_doc-line-sum.sale-sum-rubl < 0 then do:
        return - bf_doc-line-sum.sale-sum-rubl.
      end.
      else do:
        return 0.00.
      end.
    end.
  end.
  else do:
    return ?.
  end.
end function.
function fncmiss-without-wastage returns decimal ( buffer local-doc-line for ub.doc-line,
                                                   buffer local-goods for ub.goods ) :
  define buffer bf-gen_doc-line-sum  for ub.doc-line-sum.
  define buffer bf-wst_doc-line-sum  for ub.doc-line-sum.
  if varinvclcwt = yes and
     varinvclcas = yes then do:
    find first bf-gen_doc-line-sum no-lock where
               bf-gen_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf-gen_doc-line-sum.gds-code = local-goods.gds-code and
               bf-gen_doc-line-sum.sum-type = 'gen':U.
    find first bf-wst_doc-line-sum no-lock where
               bf-wst_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf-wst_doc-line-sum.gds-code = local-goods.gds-code and
               bf-wst_doc-line-sum.sum-type = 'wst':U.
    if varr-b = "base" then do:
      if bf-gen_doc-line-sum.sale-sum-base < 0 then do:
        if bf-wst_doc-line-sum.sale-sum-base >= - bf-gen_doc-line-sum.sale-sum-base then do:
          return 0.00.
        end.
        else do:
          return ( - ( bf-gen_doc-line-sum.sale-sum-base + bf-wst_doc-line-sum.sale-sum-base ) ).
        end.
      end.
      else do:
        return 0.00.
      end.
    end.
    else do:
      if bf-gen_doc-line-sum.sale-sum-rubl < 0 then do:
        if bf-wst_doc-line-sum.sale-sum-rubl >= - bf-gen_doc-line-sum.sale-sum-rubl then do:
          return 0.00.
        end.
        else do:
          return ( - ( bf-gen_doc-line-sum.sale-sum-rubl + bf-wst_doc-line-sum.sale-sum-rubl ) ).
        end.
      end.
      else do:
        return 0.00.
      end.
    end.
  end.
  else do:
    return ?.
  end.
end function.
function fncwastage returns decimal ( buffer local-doc-line for ub.doc-line,
                                      buffer local-goods for ub.goods ) :
  define buffer bf_doc-line-sum      for ub.doc-line-sum.
  define buffer bf-wst_doc-line-sum  for ub.doc-line-sum.
  if varinvclcas = yes and
     varinvclcwt = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = 'gen':U.
    find first bf-wst_doc-line-sum no-lock where
               bf-wst_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf-wst_doc-line-sum.gds-code = local-goods.gds-code and
               bf-wst_doc-line-sum.sum-type = 'wst':U.
    if bf_doc-line-sum.sale-sum-base < 0 then do:
      if varr-b = "base" then do:
        if bf-wst_doc-line-sum.sale-sum-base > - bf_doc-line-sum.sale-sum-base then do:
          return - bf_doc-line-sum.sale-sum-base.
        end.
        else do:
          return bf-wst_doc-line-sum.sale-sum-base.
        end.
      end.
      else do:
        if bf-wst_doc-line-sum.sale-sum-rubl > - bf_doc-line-sum.sale-sum-rubl then do:
          return - bf_doc-line-sum.sale-sum-rubl.
        end.
        else do:
          return bf-wst_doc-line-sum.sale-sum-rubl.
        end.
      end.
    end.
    else do:
      return 0.00.
    end.
  end.
end function.
function wasQuant returns character ( input doc-qnty as decimal,
                                      input invTSD as logical) :
define variable v-result as character no-undo .
    if invTSD and (t-doc.status_ = 'накл':U or t-doc.status_ = 'разрешен':U) and not ItogInv then v-result = "" .
    else do:
    v-result = string(doc-qnty) .
    end.
    return v-result .
end function.
function fncnode-name returns character ( buffer local-doc-line for ub.doc-line,
                                          buffer local-goods for ub.goods ) :
  define buffer local-gds-prt for ub.gds-prt.
  find first local-gds-prt where local-gds-prt.upper-code = local-goods.prt-root no-lock.
  return ( if local-gds-prt.node-name = '_Пустая шкала':U then '-' else local-gds-prt.node-name ).
end function.
function fncwast-rb returns decimal ( buffer local-doc-line for ub.doc-line,
                                      buffer local-goods for ub.goods ) :
  define buffer bf-wst_doc-line-sum for ub.doc-line-sum.
  if varinvclcwt = yes then do:
    find first bf-wst_doc-line-sum no-lock where
               bf-wst_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf-wst_doc-line-sum.gds-code = local-goods.gds-code and
               bf-wst_doc-line-sum.sum-type = 'wst':U.
    if varr-b = "base" then do:
      return bf-wst_doc-line-sum.sale-sum-base.
    end.
    else do:
      return bf-wst_doc-line-sum.sale-sum-rubl.
    end.
  end.
  else do:
    return ?.
  end.
end function.
function fncunus-wast-rb returns decimal ( buffer local-doc-line for ub.doc-line,
                                           buffer local-goods for ub.goods ) :
  define buffer bf_doc-line-sum     for ub.doc-line-sum.
  define buffer bf-wst_doc-line-sum for ub.doc-line-sum.
  if varinvclcas = yes and
     varinvclcwt = yes then do:
    find first bf_doc-line-sum no-lock where
               bf_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf_doc-line-sum.gds-code = local-goods.gds-code and
               bf_doc-line-sum.sum-type = 'gen':U.
    find first bf-wst_doc-line-sum no-lock where
               bf-wst_doc-line-sum.doc-code = local-doc-line.doc-code and
               bf-wst_doc-line-sum.gds-code = local-goods.gds-code and
               bf-wst_doc-line-sum.sum-type = 'wst':U.
    if varr-b = "base" then do:
      if bf_doc-line-sum.sale-sum-base < 0 then do:
          if bf-wst_doc-line-sum.sale-sum-base < abs(bf_doc-line-sum.sale-sum-base) then do:
            return 0.00.
          end.
          else do:
            return bf-wst_doc-line-sum.sale-sum-base - abs(bf_doc-line-sum.sale-sum-base).
          end.
      end.
      else do:
          return bf-wst_doc-line-sum.sale-sum-base.
      end.
    end.
    else do:
      if bf_doc-line-sum.sale-sum-rubl < 0 then do:
          if bf-wst_doc-line-sum.sale-sum-rubl < abs(bf_doc-line-sum.sale-sum-rubl) then do:
            return 0.00.
          end.
          else do:
            return bf-wst_doc-line-sum.sale-sum-rubl - abs(bf_doc-line-sum.sale-sum-rubl).
          end.
      end.
      else do:
          return bf-wst_doc-line-sum.sale-sum-rubl.
      end.
    end.
  end.
  else do:
    return ?.
  end.
end function.
function fncwasqntykg returns decimal ( buffer local-doc-line for ub.doc-line ) :
  define variable d_out-qnty-kg as decimal no-undo.
  run inv-line_qnty in this-procedure ( input recid( local-doc-line ), input "was",  output d_out-qnty-kg ) no-error.
  return ( if error-status :error then ? else d_out-qnty-kg ).
end function.
function fncareqntykg returns decimal ( buffer local-doc-line for ub.doc-line ) :
  define variable d_out-qnty-kg as decimal no-undo.
  run inv-line_qnty in this-procedure ( input recid( local-doc-line ), input "are",  output d_out-qnty-kg ) no-error.
  return ( if error-status :error then ? else d_out-qnty-kg ).
end function.
function fncdiffqntykg returns decimal ( buffer local-doc-line for ub.doc-line ) :
  define variable d_out-qnty-kg as decimal no-undo.
  run inv-line_qnty in this-procedure ( input recid( local-doc-line ), input "diff", output d_out-qnty-kg ) no-error.
  return ( if error-status :error then ? else d_out-qnty-kg ).
end function.
function markqnty returns integer ( buffer local-doc-line for ub.doc-line ) :
  define variable ii as integer no-undo.
  define buffer buf_marking-lines for ub.marking-lines.
  define buffer buf_marking for ub.marking.
  define buffer buf_gds for ub.goods.
  if v-is-marking = false
    then return 0.
  find first buf_gds no-lock where buf_gds.artic = local-doc-line.artic
    and buf_gds.prod-type = local-doc-line.prod-type
    and buf_gds.prod-code = local-doc-line.prod-code.
  for each buf_marking-lines where buf_marking-lines.obj-type = local-doc-line.obj-type and buf_marking-lines.obj-code = local-doc-line.obj-code
    and buf_marking-lines.gds-code = buf_gds.gds-code and buf_marking-lines.out-code = 'free-zone':U and not buf_marking-lines.mark begins 'tech_':U
    :
    if not can-find (first ub.marking where ub.marking.mark = buf_marking-lines.mark and ub.marking.unit-ext = "UNIT")
    then next.
    ii = ii + 1.
  end.
  return ii.
end function.
function markqntytech returns integer ( buffer local-doc-line for ub.doc-line ) :
  define variable ii as integer no-undo.
  define buffer buf_marking-lines for ub.marking-lines.
  define buffer buf_marking for ub.marking.
  define buffer buf_gds for ub.goods.
  if v-is-marking = false
    then return 0.
  find first buf_gds no-lock where buf_gds.artic = local-doc-line.artic
    and buf_gds.prod-type = local-doc-line.prod-type
    and buf_gds.prod-code = local-doc-line.prod-code.
  for each buf_marking-lines where buf_marking-lines.obj-type = local-doc-line.obj-type and buf_marking-lines.obj-code = local-doc-line.obj-code
    and buf_marking-lines.gds-code = buf_gds.gds-code and buf_marking-lines.out-code = 'free-zone':U and buf_marking-lines.mark begins 'tech_':U
    :
    if not can-find (first ub.marking where ub.marking.mark = buf_marking-lines.mark and ub.marking.unit-ext = "UNIT")
    then next.
    ii = ii + 1.
  end.
  return ii.
end function.
function markqntycheckinv returns integer ( buffer local-doc-line for ub.doc-line ) :
  define variable ii as integer no-undo.
  run procmarkqntycheckinv (buffer local-doc-line, output ii).
  return ii.
end function.
procedure procmarkqntycheckinv:
  define parameter buffer local-doc-line for ub.doc-line.
  define output parameter ii as integer no-undo.
  define buffer buf_marking-lines for ub.marking-lines.
  define buffer buf_marking for ub.marking.
  define buffer buf_gds for ub.goods.
  define buffer buf_utd-marking-lines for ub.utd-marking-lines.
  if not v-is-introduce and not v-is-marking
  then
     return.
  if v-is-marking = false
    then ii = 0.
  find first buf_gds no-lock where buf_gds.artic = local-doc-line.artic
    and buf_gds.prod-type = local-doc-line.prod-type
    and buf_gds.prod-code = local-doc-line.prod-code.
  for each ub.marking-attr no-lock where (    ub.marking-attr.attr-code = "inv-doc"
                                          and ub.marking-attr.attr-value = ub.doc-line.doc-code)
                                     or  (    ub.marking-attr.attr-code = "inv-doc-scan"
                                          and ub.marking-attr.attr-value = ub.doc-line.doc-code ):
    if not can-find (first ub.marking no-lock where ub.marking.mark = ub.marking-attr.mark and ub.marking.unit-ext = "UNIT" and ub.marking.gds-code = buf_gds.gds-code)
      then next.
    ii = ii + 1.
  end.
  for each ub.utd no-lock where ub.utd.doc-code = local-doc-line.doc-code:
    for each ub.utd-marking-lines no-lock where (    ub.utd-marking-lines.doc-id = ub.utd.doc-id
                                                 and ub.utd-marking-lines.db-num = ub.utd.db-num
                                                 and ub.utd-marking-lines.gds-code = buf_gds.gds-code
                                                 and ub.utd-marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:PendingVerification:KeyIntDB )
                                             or (    ub.utd-marking-lines.doc-id = ub.utd.doc-id
                                                 and ub.utd-marking-lines.db-num = ub.utd.db-num
                                                 and ub.utd-marking-lines.gds-code = buf_gds.gds-code
                                                 and ub.utd-marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB):
      for each ub.marking no-lock where ub.marking.mark = ub.utd-marking-lines.mark.
        if can-find (buf_utd-marking-lines where
              buf_utd-marking-lines.doc-id = ub.utd.doc-id and buf_utd-marking-lines.db-num = ub.utd.db-num and buf_utd-marking-lines.mark = ub.marking.mark-parent
            )
          then next.
        ii = ii + ub.marking.box-qnty.
      end.
    end.
  end.
end.
define button b-inv-prsrt
     label "ИПерср":l
     tooltip "Итоги по колонке пересортице"
     size 9 by 1.
define button b-notes
     label "При&м":l
     size 9 by 1.
define button b-alcmark
     label "АлкМарк":l
     size 9 by 1.
DEFINE BUTTON b-attr
     LABEL "А&трибуты"
     SIZE 9 BY 1.
define button b-add
     label "&Добав":l
     size 9 by 1.
define button b-arch
     label "Уч&ет"
     size 9 by 1.
define button b-cnt
     label "&ДогП":l
     size 9 by 1.
define button b-clr
     label "С&брос":l
     size 9 by 1.
define button b-st
     label "&Восст":l
     size 9 by 1.
define button b-parts-
     label "&Партии-":l
     size 9 by 1.
define button b-updprt-
     label "&РедПарт-":l
     size 9 by 1.
define button b-del
     label "&Удал":l
     size 9 by 1.
define button b-exit auto-go
     label "&Выход ":l
     size 9 by 1.
define button b-help
     label "Помо&щь":l
     size 9 by 1.
define button b-chg
     label "&Измен":l
     size 9 by 1.
define button b-parts
     label "Па&ртии":l
     size 9 by 1.
define button b-chk-doc
     label "&Чеки":l
     size 9 by 1.
define button b-list
     label "&Список":l
     size 9 by 1.
define button b-lkp
     label "&Просм":l
     size 9 by 1.
define button b-sum-doc
     label "&СумДок":l
     size 9 by 1.
define button b-sum-goods
     label "&СумТов":l
     size 9 by 1.
define button b-history
     label "Ис&тор":l
     size 9 by 1.
define button b-unscn
     label "Файлы":l
     size 9 by 1.
define button b-next auto-go
     label "&>>":l
     size 4.5 by 1
     bgcolor 8 .
define button b-prev auto-go
     label "&<<":l
     size 4.5 by 1
     bgcolor 8 .
define button r-agnt
     image-up          file "btn-down-arrow"
     image-down        file "btn-down-arrow"
     image-insensitive file "btn-down-arrow"
     size 3 by .88.
define button r-sht
     image-up          file "btn-down-arrow":u
     image-down        file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     size 3 by .88.
define button b-marks
     label "Марки":l
     size 9 by 1.
define button r-boss like r-agnt.
define button r-wrkr like r-agnt.
define button r-reas like r-agnt.
define menu m-clr
    menu-item m-clr-1   label "Текущей строки"          accelerator "alt-1"
    menu-item m-clr-2   label "Всех строк"              accelerator "alt-2"
    menu-item m-clr-3   label "Нередактированных строк" accelerator "alt-3".
define menu m-parts-
    menu-item m-parts-1 label "Текущей строки"          accelerator "alt-1"
    menu-item m-parts-2 label "Всех строк"              accelerator "alt-2".
define menu m-st
    menu-item m-st-1    label "Текущей строки"          accelerator "alt-1"
    menu-item m-st-2    label "Всех строк"              accelerator "alt-2"
    menu-item m-st-3    label "Нулевых строк"           accelerator "alt-3".
DEFINE MENU m-chk-doc
      MENU-ITEM m-chk-docs        LABEL "Список чеков по документу"     ACCELERATOR "ALT-1"
      MENU-ITEM m-chk-doc-add     LABEL "Добавить из чеков"  ACCELERATOR "ALT-2"
      MENU-ITEM m-chk-gds         LABEL "Строки"  ACCELERATOR "ALT-3"
      .
define menu m-marks
  menu-item m_add-marks           label "Добавить"
  menu-item m_introduce-marks     label "Установить флаг первоначального ввода".
  menu-item m_lookup              label "Просмотр".
define variable agnt-name as character format "x(256)":U
      view-as text
     size 9 by 1 no-undo.
define variable boss-name as character format "x(256)":U
      view-as text
     size 9 by 1 no-undo.
define variable wrkr-name as character format "x(256)":U
      view-as text
     size 9 by 1 no-undo.
define variable rsn-name as character no-undo format "x(256)":U view-as fill-in size 51.5 by .88 fgcolor 4.
define variable loc-art  as character format "x(16)" view-as fill-in size 20 by 1 fgcolor 12 no-undo.
define variable loc-name as character view-as fill-in size 20 by 1 fgcolor 12 no-undo.
define variable loc-code as character view-as fill-in size 20 by 1 fgcolor 12 no-undo.
define variable a-n-c as character view-as radio-set horizontal radio-buttons
"&А","art",
"&Н","name",
"&К","code"
size 12 by 1 no-undo.
define variable dif-only as character view-as radio-set vertical radio-buttons
"Все&.", "all":u,
"И&зл", "surplus":u,
"Нед&", "shortage":u,
"Со&в", "coincidence":u,
"Ма&р", "markseqdocqnty":u
size 7 by 4 no-undo.
define variable prt-mark as   character            no-undo.
define variable inv-mark as   character            no-undo.
define variable scl-name like ub.gds-prt.node-name no-undo.
define query br-list for ub.doc-line except , ub.goods except
.
DEFINE VARIABLE invTSD AS LOGICAL INITIAL no
     LABEL "ТСД"
     VIEW-AS TOGGLE-BOX
     SIZE 10.4 BY .81 NO-UNDO.
define browse br-list query br-list no-lock display
    fncgele( buffer ub.doc-line )   @ inv-mark              column-label 'К' format "x(1)":U  if ub.doc-line.prt-OK then '*' else ''   @ prt-mark              column-label 'Ш' format "x(1)":U  ub.doc-line.artic                           column-label 'Артикул'  ub.goods.gds-name                           column-label 'Имя ' format "x(150)":U  fncdiffqntykg( buffer ub.doc-line )  @ vardiff-qnty-kg       column-label 'Разница, кг' format "->>>,>>>,>>9.999":U  markqnty( buffer ub.doc-line )  @ var-qnty-mark         column-label 'Кол-во марок' format ">>>>9":U  markqntycheckinv( buffer ub.doc-line )  @ var-qnty-mark-chk     column-label 'Проверено марок' format ">>>>9":U  markqntytech( buffer ub.doc-line )  @ var-qnty-mark-tech    column-label 'Тех. марки' format ">>>>9":U  fncwasqntykg( buffer ub.doc-line )  @ varwas-qnty-kg        column-label 'Было, кг' format "->>>,>>>,>>9.999":U  fncareqntykg( buffer ub.doc-line )  @ varare-qnty-kg        column-label 'Стало, кг' format "->>>,>>>,>>9.999":U  fncdiffqntykg( buffer ub.doc-line )  @ vardiff-qnty-kg       column-label 'Разница, кг' format "->>>,>>>,>>9.999":U  ub.doc-line.doc-qnty - ub.doc-line.fact-qnty   @ varbefore-qnty        column-label 'Было'  wasQuant(ub.doc-line.doc-qnty, invTSD)   @ vdoc-qnty             column-label 'Стало'  ub.doc-line.fact-qnty                           column-label 'Разница'  ub.doc-line.vat-pc                          column-label 'НДС' format ">9.9%":U  ub.goods.unit-base                           column-label 'Ед. изм.'  fncextra-qnty( buffer ub.doc-line )  @ varextra-qnty         column-label 'Излишки'  fncmiss-qnty( buffer ub.doc-line )  @ varmiss-qnty          column-label 'Недостача'  fncbefore-base( buffer ub.doc-line, buffer ub.goods )  @ varbefore-base        column-label 'Было! учет цены(вал)'  fncbefore-rubl( buffer ub.doc-line, buffer ub.goods )  @ varbefore-rubl        column-label 'Было! учет цены(руб)'  fncafter-base( buffer ub.doc-line, buffer ub.goods )  @ varafter-base         column-label 'Стало! учет цены(вал)'  fncafter-rubl( buffer ub.doc-line, buffer ub.goods )  @ varafter-rubl         column-label 'Стало! учет цены(руб)'  fncextra-base( buffer ub.doc-line, buffer ub.goods )  @ varextra-base         column-label 'Излишки! учет цены(вал)'  fncextra-rubl( buffer ub.doc-line, buffer ub.goods )  @ varextra-rubl         column-label 'Излишки! учет цены(руб)'  fncmiss-base( buffer ub.doc-line, buffer ub.goods )  @ varmiss-base          column-label 'Недостача! учет цены(вал)'  fncmiss-rubl( buffer ub.doc-line, buffer ub.goods )  @ varmiss-rubl          column-label 'Недостача! учет цены(руб)'  fncbefore-rb( buffer ub.doc-line, buffer ub.goods )  @ varbefore-rb          column-label 'Было! прод цены'  fncafter-rb( buffer ub.doc-line, buffer ub.goods )  @ varafter-rb           column-label 'Стало! прод цены'  fncextra-rb( buffer ub.doc-line, buffer ub.goods )  @ varextra-rb           column-label 'Излишки! прод цены'  fncmiss-rb( buffer ub.doc-line, buffer ub.goods )  @ varmiss-rb            column-label 'Недостача! прод цены'  fncmiss-without-wastage( buffer ub.doc-line, buffer ub.goods )  @ varmiss-without-wast  column-label 'Нед. без ест. уб.! прод цены'  fncwastage( buffer ub.doc-line, buffer ub.goods )  @ varwastage            column-label 'Ест. убыль! прод цены'  fncwast-rb( buffer ub.doc-line, buffer ub.goods )  @ varwast-rb            column-label 'Фонд. ест. убыли! прод цены'  fncunus-wast-rb( buffer ub.doc-line, buffer ub.goods )  @ varunus-wast-rb       column-label 'Неизр. ест. убыль! прод цены'  ub.goods.gds-code                          column-label 'Код товара' FORMAT "99999999999":U  ub.doc-line.inv-peresort-qnty                          column-label 'Пересортица' format "->>>,>>>,>>9.999":U  fncnode-name( buffer ub.doc-line, buffer ub.goods )   @ scl-name              column-label 'Шкала' format "x(10)":U
    enable ub.doc-line.fact-qnty
    with size 97 by 10.5 separators.
define variable fi-val-header as character format "x(5)":U initial " ВАЛ "
     view-as fill-in
     size 5.9 by 0.60
     bgcolor cyan_color fgcolor white_color .
define variable fi-rub-header as character format "x(5)":U initial " РУБ "
     view-as fill-in
     size 5.9 by 0.60
     bgcolor cyan_color fgcolor white_color .
define variable fi-plusbal-header as character format "x(15)":U initial " Положительный "
     view-as fill-in
     size 15.9 by 0.60
     bgcolor cyan_color fgcolor white_color .
define variable fi-minusbal-header as character format "x(15)":U initial " Отрицательный "
     view-as fill-in
     size 15.9 by 0.60
     bgcolor cyan_color fgcolor white_color .
define variable fi-izlishki-header as character format "x(9)":U initial " ИЗЛИШКИ "
     view-as fill-in
     size 9.9 by 0.60
     bgcolor cyan_color fgcolor white_color .
define variable fi-nedostacha-header as character format "x(11)":U initial " НЕДОСТАЧА "
     view-as fill-in
     size 11.9 by 0.60
     bgcolor cyan_color fgcolor white_color .
define variable fi-raschet-header as character format "x(20)":U initial "РАСЧЁТ ПРИ ИЗМЕНЕНИИ"
     view-as fill-in
     size 20.9 by 0.60
     bgcolor cyan_color fgcolor white_color .
define variable t-othermoves as logical
     LABEL "Прочие перемещения НП"
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY .77 NO-UNDO.
define frame d-inv-doc
  b-exit                       at row 1   col 1
  b-prev                       at row 1   col 10
  b-next                       at row 1   col 14.5
  b-add                        at row 1   col 19
  b-lkp                        at row 1   col 28
  b-chg                        at row 1   col 37
  b-clr                        at row 1   col 46
  b-st                         at row 1   col 55
  b-del                        at row 1   col 64
  b-cnt                        at row 1   col 73
  b-chk-doc                    at row 1   col 82
  b-help                       at row 1   col 91
  b-sum-doc                    at row 2   col 1
  b-sum-goods                  at row 2   col 10
  b-arch                       at row 2   col 19
  b-list                       at row 2   col 28
  b-unscn                      at row 2   col 37
  b-notes                      at row 2   col 46
  b-alcmark                    at row 2   col 55
  b-parts-                     at row 2   col 64
  b-updprt-                    at row 2   col 73
  b-parts                      at row 2   col 82
  b-history                    at row 2   col 91
  t-doc.doc-date AT ROW 3 COL 7 COLON-ALIGNED
    VIEW-AS FILL-IN
    SIZE 9 BY .88
    FGCOLOR 4
  t-doc.fact-date AT ROW 3 COL 22.25 COLON-ALIGNED
    VIEW-AS FILL-IN
    SIZE 9 BY .88
    FGCOLOR 4
  t-doc.shift-date AT ROW 3 COL 38.25 COLON-ALIGNED
    LABEL "&Смена"
    VIEW-AS FILL-IN
    SIZE 9 BY .88
    FGCOLOR 4
  t-doc.shift-name AT ROW 3 COL 50.38 COLON-ALIGNED
    LABEL "&№"
    VIEW-AS FILL-IN
    SIZE 3 BY .88 TOOLTIP "Номер смены"
    FGCOLOR 4
  t-doc.shift-num AT ROW 3 COL 56.5 COLON-ALIGNED
    LABEL "П"
    VIEW-AS FILL-IN
    SIZE 3 BY .88 TOOLTIP "Порядок смен"
    FGCOLOR 4
  r-sht AT ROW 3 COL 61.5
  b-attr                       at row 3   col 82
  rect-trn-doc                 at row 4.2 col 1
  rect-inv-doc                 at row 6.7 col 1
  rect-tog                     at row 6.7 col 48
  fi-val-header                at row 4   col 15                 no-label
  invTSD                       AT ROW 3.14 COL 70                WIDGET-ID 2
  fi-rub-header                at row 4   col 33                 no-label
  fi-plusbal-header            at row 4   col 18                 no-label
  fi-minusbal-header           at row 4   col 37                 no-label
  t-doc.tot-doc                at row 4.6 col 7    colon-aligned    label "Прод."                 view-as fill-in    size 17 by 1.00 fgcolor 4
  t-doc.tot-rubl               at row 4.6 col 24   colon-aligned no-label                         view-as fill-in    size 17 by 1.00 fgcolor 4
  t-doc.fact-base              at row 5.5 col 7    colon-aligned    label "Учет."                 view-as fill-in    size 17 by 1.00 fgcolor 4
  t-doc.fact-rubl              at row 5.5 col 24   colon-aligned no-label                         view-as fill-in    size 17 by 1.00 fgcolor 4
  t-doc.doc-qnty               at row 4.6 col 48   colon-aligned    label "Было "                 view-as fill-in    size 15 by 1.00 fgcolor 4
  t-doc.fact-qnty              at row 5.5 col 48   colon-aligned    label "Разн."                 view-as fill-in    size 15 by 1.00 fgcolor 4
  fi-izlishki-header           at row 6.4 col 19                 no-label
  vardocextra-qnty             at row 7   col 14   colon-aligned    label "Количество  "          view-as fill-in    size 15 by 1.00 fgcolor 4
  vardocextra-base             at row 8.8 col 14   colon-aligned    label "Учетные(вал)"          view-as fill-in    size 15 by 1.00 fgcolor 4
  vardocextra-rubl             at row 7.9 col 14   colon-aligned    label "Учетные(руб)"  view-as fill-in    size 15 by 1.00 fgcolor 4
  vardocextra-rb               at row 9.7 col 14   colon-aligned    label "Продажные   "          view-as fill-in    size 15 by 1.00 fgcolor 4
  fi-nedostacha-header         at row 6.4 col 34                 no-label
  vardocmiss-qnty              at row 7   col 30   colon-aligned no-label                         view-as fill-in    size 15 by 1.00 fgcolor 4
  vardocmiss-base              at row 8.8 col 30   colon-aligned no-label                         view-as fill-in    size 15 by 1.00 fgcolor 4
  vardocmiss-rubl              at row 7.9 col 30   colon-aligned no-label                         view-as fill-in    size 15 by 1.00 fgcolor 4
  vardocmiss-rb                at row 9.7 col 30   colon-aligned no-label                         view-as fill-in    size 15 by 1.00 fgcolor 4
  vardocwast-rb                at row 8.5 col 80   colon-aligned    label "Фонд е.у."             view-as fill-in    size 15 by 1.00 fgcolor 4
  t-doc.re-grading-parts-minus at row 9.5 col 68   colon-aligned    label "Пересорт.отриц.партий" view-as toggle-box size 24 by 0.77 fgcolor 4
  fi-raschet-header            at row 6.4 col 48.3               no-label
  varinvclcwtol                at row 8.2 col 46.5 colon-aligned
  varinvclcasol                at row 9.4 col 46.5 colon-aligned
  t-doc.wrkr                   at row 4   col 75   colon-aligned no-label                         view-as fill-in    size 10 by 1.00 format "999999999":U
  wrkr-name                    at row 4   col 85.5 colon-aligned no-label                                                            fgcolor 4
  r-wrkr                       at row 4   col 96                 no-label
  t-doc.agnt                   at row 5   col 75   colon-aligned no-label                         view-as fill-in    size 10 by 1.00 format "999999999":U
  agnt-name                    at row 5   col 85.5 colon-aligned no-label                                                            fgcolor 4
  r-agnt                       at row 5   col 96                 no-label
  t-doc.boss                   at row 6   col 75   colon-aligned no-label                         view-as fill-in    size 10 by 1.00 format "999999999":U
  boss-name                    at row 6   col 85.5 colon-aligned no-label                                                            fgcolor 4
  r-boss                       at row 6   col 96                 no-label
  t-doc.reason-code            at row 11  col 8   colon-aligned    label "Осн.д."   view-as fill-in    size 3 by  .88 format ">>9":U
  r-reas                       at row 11  col 14
  b-marks                      at row 2   col 55
  rsn-name                     at row 11  col 18                 no-label
  t-othermoves                 at row 11  col 68  colon-aligned
  br-list               at row 12  col 1.5
  dif-only                     at row 4   col 68   colon-aligned no-label
  a-n-c                        at row 10.2  col 80                 no-label
  loc-art                      at row 11  col 76   colon-aligned    label "Начало артикула"
  loc-name                     at row 11  col 76   colon-aligned    label "Начало названия"                                          format "x(40)":U
  loc-code                     at row 11  col 76   colon-aligned    label "Бар-код (весь)"                                           format "x(13)":U
  b-inv-prsrt                  at row 2   col 91
  f-notbal AT ROW 4.6 COL 16.63 COLON-ALIGNED WIDGET-ID 2
  f-notbal-2 AT ROW 4.6 COL 34.5 COLON-ALIGNED NO-LABEL WIDGET-ID 18
  f-acc AT ROW 5.6 COL 16.63 COLON-ALIGNED WIDGET-ID 4
  f-acc-2 AT ROW 5.6 COL 34.5 COLON-ALIGNED NO-LABEL WIDGET-ID 16
  f-meu AT ROW 6.6 COL 1.3 COLON-ALIGNED WIDGET-ID 6 no-labels
  f-meu-2 AT ROW 6.6 COL 34.5 COLON-ALIGNED NO-LABEL WIDGET-ID 20
  f-mnorml AT ROW 7.6 COL 1.3 COLON-ALIGNED WIDGET-ID 8 no-labels
  f-mnorml-2 AT ROW 7.6 COL 34.5 COLON-ALIGNED NO-LABEL WIDGET-ID 22
  f-izlnedos AT ROW 9.6 COL 16.63 COLON-ALIGNED WIDGET-ID 10
  f-izlnedos-2 AT ROW 9.6 COL 34.5 COLON-ALIGNED NO-LABEL WIDGET-ID 24
  f-izlheader AT ROW 8.6 COL 1.3 COLON-ALIGNED NO-LABEL WIDGET-ID 24
  space( 0 ) skip( 0 )
with view-as dialog-box keep-tab-order
     side-labels no-underline three-d scrollable
     default-button b-exit.
assign
  b-marks:popup-menu in frame d-inv-doc = menu m-marks:handle.
assign
  b-marks:menu-mouse = 1.
assign
  frame d-inv-doc :scrollable                    = false
  br-list :num-locked-columns in frame d-inv-doc = 3
  b-clr    :popup-menu in frame d-inv-doc    = menu m-clr :handle
  b-clr    :menu-mouse                           = 1
  b-st     :popup-menu in frame d-inv-doc    = menu m-st :handle
  b-st     :menu-mouse                           = 1
  b-parts- :popup-menu in frame d-inv-doc    = menu m-parts- :handle
  b-parts- :menu-mouse                           = 1.
assign
  r-reas            :tooltip in frame d-inv-doc = "Основание (причина) создания документа. Вызов справочника"
  t-doc.reason-code :tooltip in frame d-inv-doc = "Основание (причина) создания документа. Ввод кода"
  rsn-name          :tooltip in frame d-inv-doc = "Основание (причина) создания документа"
.
assign
  parext-doc-mode =
    ( if num-entries( pardoc-mode, '*':U ) > 1 then entry( 2, pardoc-mode, '*':U ) else '':U )
  pardoc-mode     = entry( 1, pardoc-mode, '*':U )
.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'inv-prsr'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-inv-prsr
  ,output v-data-type
  ) no-error .
if error-status :error then v-inv-prsr = "no" .
ub.doc-line.inv-peresort:visible in browse br-list  = (if v-inv-prsr = "yes" then true else false ) .
def var sort-labelbr-list   as character no-undo .
def var sort-clmnbr-list    as handle    no-undo .
def var cur-clmnbr-list     as handle    no-undo .
def var cur-clmn-locbr-list as integer   no-undo .
def var re-querybr-list     as logical   initial no no-undo .
on start-search, ctrl-o of br-list in frame d-inv-doc do:
   run sort-brbr-list
     (input (if available ub.doc-line
             then recid(ub.doc-line)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-list :
  define input parameter p-recid as recid no-undo .
  ASSIGN dif-only = "all". DISPLAY dif-only WITH FRAME d-inv-doc.
  if re-querybr-list = no then do:
    assign
       cur-clmnbr-list = br-list:current-column in frame d-inv-doc
    .
    if sort-clmnbr-list <> ? then sort-clmnbr-list:column-fgcolor = 0.
    if cur-clmnbr-list = sort-clmnbr-list then do:
      assign
         sort-labelbr-list = ""
         sort-clmnbr-list = ?
      .
     end.
     else do:
       assign
         sort-labelbr-list = cur-clmnbr-list:label
         sort-clmnbr-list  = cur-clmnbr-list
         sort-clmnbr-list:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-list = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-list:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-list then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-list = cur-clmn-locbr-list + 1
    .
  end.
  case sort-labelbr-list:
        when 'К'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY fncgele( buffer ub.doc-line ).   . END.
        when 'Ш'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY if ub.doc-line.prt-OK then '*' else ''.   . END.
        when 'Артикул'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY ub.doc-line.artic.   . END.
        when 'Имя '  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY ub.goods.gds-name.   . END.
        when 'Шкала'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY fncnode-name( buffer ub.doc-line, buffer ub.goods ).   . END.
        when 'Было'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY ub.doc-line.doc-qnty - ub.doc-line.fact-qnty DESCENDING.   . END.
        when 'Стало'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY wasQuant(ub.doc-line.doc-qnty, invTSD) DESCENDING.   . END.
        when 'Разница'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY ub.doc-line.fact-qnty DESCENDING.   . END.
        when 'Ед. изм.'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY ub.goods.unit-base.   . END.
        when 'Излишки'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY fncextra-qnty( buffer ub.doc-line ) DESCENDING.   . END.
        when 'Недостача'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY fncmiss-qnty( buffer ub.doc-line ) DESCENDING.   . END.
        when 'Было! учет цены(вал)'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY fncbefore-base( buffer ub.doc-line, buffer ub.goods ) DESCENDING.   . END.
        when 'Было! учет цены(руб)'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY fncbefore-rubl( buffer ub.doc-line, buffer ub.goods ) DESCENDING.   . END.
        when 'Стало! учет цены(вал)'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY fncafter-base( buffer ub.doc-line, buffer ub.goods ) DESCENDING.   . END.
        when 'Стало! учет цены(руб)'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY fncafter-rubl( buffer ub.doc-line, buffer ub.goods ) DESCENDING.   . END.
        when 'Излишки! учет цены(вал)'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY fncextra-base( buffer ub.doc-line, buffer ub.goods ) DESCENDING.   . END.
        when 'Излишки! учет цены(руб)'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY fncextra-rubl( buffer ub.doc-line, buffer ub.goods ) DESCENDING.   . END.
        when 'Недостача! учет цены(вал)'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY fncmiss-base( buffer ub.doc-line, buffer ub.goods ) DESCENDING.   . END.
        when 'Недостача! учет цены(руб)'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY fncmiss-rubl( buffer ub.doc-line, buffer ub.goods ) DESCENDING.   . END.
        when 'Было! прод цены'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY fncbefore-rb( buffer ub.doc-line, buffer ub.goods ) DESCENDING.   . END.
        when 'Стало! прод цены'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY fncafter-rb( buffer ub.doc-line, buffer ub.goods ) DESCENDING.   . END.
        when 'Излишки! прод цены'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY fncextra-rb( buffer ub.doc-line, buffer ub.goods ) DESCENDING.   . END.
        when 'Недостача! прод цены'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY fncmiss-rb( buffer ub.doc-line, buffer ub.goods ) DESCENDING.   . END.
        when 'Нед. без ест. уб.! прод цены'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY fncmiss-without-wastage( buffer ub.doc-line, buffer ub.goods ) DESCENDING.   . END.
        when 'Ест. убыль! прод цены'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY fncwastage( buffer ub.doc-line, buffer ub.goods ) DESCENDING.   . END.
        when 'Фонд. ест. убыли! прод цены'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY fncwast-rb( buffer ub.doc-line, buffer ub.goods ) DESCENDING.   . END.
        when 'Неизр. ест. убыль! прод цены'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY fncunus-wast-rb( buffer ub.doc-line, buffer ub.goods ) DESCENDING.   . END.
        when 'Код товара'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY ub.goods.gds-code DESCENDING.   . END.
        when 'Было, кг'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY fncwasqntykg( buffer ub.doc-line ) DESCENDING.   . END.
        when 'Стало, кг'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY fncareqntykg( buffer ub.doc-line ) DESCENDING.   . END.
        when 'Разница, кг'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY fncdiffqntykg( buffer ub.doc-line ) DESCENDING.   . END.
        when 'Пересортица'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY ub.doc-line.inv-peresort-qnty DESCENDING.   . END.
        when 'НДС'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY ub.doc-line.vat-pc DESCENDING.   . END.
        when 'Кол-во марок'  then DO:   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY markqnty( buffer ub.doc-line ) DESCENDING.   . END.
    otherwise do:
      open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY ub.doc-line.line-num.
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr-list') then do:
          run mv-brw-defaultbr-list.
        end.
      if sort-labelbr-list <> "" then do:
        assign
          cur-clmnbr-list:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-list = ?
      .
    end.
  end case.
    if cur-clmn-locbr-list <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbr-list') then do:
        run ch-clmnbr-list in this-procedure (cur-clmn-locbr-list).
      end.
    end.
  if p-recid <> ? then do:
    reposition br-list to recid p-recid no-error.
    apply "value-changed" to br-list in frame d-inv-doc.
  end.
  apply "entry" to br-list in frame d-inv-doc.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-list:
if cur-clmnbr-list = ? then do:
   open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code BY ub.doc-line.line-num.
end.
else do:
   assign re-querybr-list = yes.
   run sort-brbr-list
     (input (if available ub.doc-line
             then recid(ub.doc-line)
             else ?
            )
     ).
   assign re-querybr-list = no.
end.
end.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame d-inv-doc anywhere do:
  run fnd-goods.
  if gds-rec = ? then
    return no-apply.
  run ref/gds-form.w ( input parparentproc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to br-list in frame d-inv-doc.
  return no-apply.
end.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function func-get-name-from-ext-type   returns char
  ( p-ext-type as character   ,
    p-caps     as logical ).
define variable v-ext-name as character no-undo .
run get-name-from-ext-type in this-procedure (
    input p-ext-type  ,
    input p-caps  ,
    output v-ext-name )
    no-error .
    if error-status :error then do:
       assign
         v-ext-name = p-ext-type
       .
    end.
 return (v-ext-name) .
end.
procedure get-name-from-ext-type :
 do
 on error undo, return error return-value
 :
define input  parameter p-ext-type as character no-undo .
define input  parameter p-caps     as logical no-undo   .
define output parameter p-ext-name as character no-undo .
define variable v-num as integer no-undo .
  if lookup ( p-ext-type , 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ) = 0 then do :
    message
      vss-include-info37 skip
      "Неправильно задано значение входящего параметра! "
      "Нет такого типа документов " p-ext-type
      view-as alert-box error .
      undo, return error .
  end.
  v-num      = lookup ( p-ext-type , 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ) .
  p-ext-name = entry  ( v-num , 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U ) .
  if p-caps  = true then do :
     p-ext-name = caps(substring(p-ext-name,1,1) ) + substring(p-ext-name, 2 , length (p-ext-name) - 1 ) .
  end .
  end.
end procedure.
define variable vss-include-info38 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame d-inv-doc anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame d-inv-doc. END.
  return no-apply.
end.
define variable vss-include-info39 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame d-inv-doc anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame d-inv-doc. END.
  return no-apply.
end.
define variable vss-include-info40 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame d-inv-doc anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame d-inv-doc. END.
  return no-apply.
end.
define variable vss-include-info41 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame d-inv-doc anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame d-inv-doc. END.
  return no-apply.
end.
ON CHOOSE OF b-next IN FRAME d-inv-doc
DO:
  RUN step-next in this-procedure .
END.
procedure step-next:
define variable cur-form as char no-undo.
define variable new-form as char no-undo.
define buffer new_trn-doc for ub.trn-doc  .
case t-doc.doc-type:
  when 'при':U then
    cur-form = if t-doc.internal then 'рас':U else 'при':U.
  when 'рас':U or when 'возврат':U or when 'спи':U then
    cur-form = 'рас':U.
  when 'инв':U then cur-form = 'инв':U.
end case.
if bf-handle = ? then return .
if valid-handle (br-handle) then do:
  varlog = br-handle:select-next-row().
  find first new_trn-doc no-lock where  recid( new_trn-doc ) = bf-handle:recid no-error .
  if not varlog then message "Это последний документ списка.".
end.
case new_trn-doc.doc-type:
  when 'при':U then
    new-form = if new_trn-doc.internal then 'рас':U else 'при':U.
  when 'рас':U or when 'возврат':U or when 'спи':U then
    new-form = 'рас':U.
  when 'инв':U then new-form = 'инв':U.
end case.
assign
    pardoc-rec   = bf-handle:recid
    parnext-prev = ( cur-form = new-form ) .
end procedure.
ON CHOOSE OF b-prev IN FRAME d-inv-doc
DO:
  run step-prev in this-procedure .
END.
procedure step-prev:
define variable cur-form as char no-undo.
define variable new-form as char no-undo.
define buffer new_trn-doc for ub.trn-doc  .
case t-doc.doc-type:
  when 'при':U then if t-doc.internal then cur-form = 'рас':U. else cur-form = 'при':U.
  when 'рас':U or when 'возврат':U or when 'спи':U then cur-form = 'рас':U.
  when 'инв':U then cur-form = 'инв':U.
end case.
if bf-handle = ? then return .
if valid-handle (br-handle) then do:
  varlog = br-handle:select-prev-row().
  find first new_trn-doc no-lock where  recid( new_trn-doc ) = bf-handle:recid no-error .
  if not varlog then message "Это первый документ списка.".
end.
case new_trn-doc.doc-type :
  when 'при':U then if new_trn-doc.internal then new-form = 'рас':U. else new-form = 'при':U.
  when 'рас':U or when 'возврат':U or when 'спи':U then  new-form = 'рас':U.
  when 'инв':U then new-form = 'инв':U.
end case.
assign
  pardoc-rec   = bf-handle:recid
  parnext-prev = (cur-form = new-form)
.
end procedure.
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure ver-clients :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-error as logical   no-undo .
define variable v-veto-man-doc as character no-undo .
define variable v-type        as character no-undo .
  do
  on error undo, return error return-value
  :
  p-error = false .
run clntattr-value in this-procedure (
 input p-obj-type ,
 input p-obj-code ,
 input 'veto-man-doc':U     ,
 output v-veto-man-doc ,
 output v-type        ) no-error .
 if error-status :error then message
   error-status :get-message(1) skip
   return-value skip
   "Ошибка clntattr-veto-man-doc"
   view-as alert-box error
 .
  if v-veto-man-doc = 'ALL' then do:
      message "Запрещено создание документа на этого контрагента оператору вручную." view-as alert-box error  .
      p-error = true .
  end.
 end.
end procedure.
on end-error, stop of frame d-inv-doc do:
  apply "choose" to b-exit in frame d-inv-doc.
  return no-apply.
end.
on choose of b-notes in frame d-inv-doc run notes-tr.
on choose of b-history   in frame d-inv-doc do:
  run proc-history in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of b-exit  in frame d-inv-doc
do:
  run proc-exit no-error.
  if error-status :error then do: return no-apply. end.
end.
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON MOUSE-SELECT-DBLCLICK, return OF t-doc.agnt IN FRAME d-inv-doc
DO:
  run local-psn-chk ("agnt", "ret-mouse").
  apply "entry" to t-doc.boss in frame d-inv-doc.
  return no-apply.
END.
ON MOUSE-SELECT-DBLCLICK, return OF t-doc.boss IN FRAME d-inv-doc
DO:
  RUN local-psn-chk ("boss", "ret-mouse").
  apply "entry" to b-exit in frame d-inv-doc.
  return no-apply.
END.
ON MOUSE-SELECT-DBLCLICK, return OF t-doc.wrkr IN FRAME d-inv-doc
DO:
  RUN local-psn-chk ("wrkr", "ret-mouse").
  apply "entry" to t-doc.agnt in frame d-inv-doc.
  return no-apply.
END.
ON CHOOSE OF r-agnt IN FRAME d-inv-doc
DO:
  RUN local-psn-chk ("agnt", "button").
  apply "entry" to t-doc.boss in frame d-inv-doc.
  return no-apply.
END.
ON CHOOSE OF r-boss IN FRAME d-inv-doc
DO:
  RUN local-psn-chk ("boss", "button").
  apply "entry" to b-exit in frame d-inv-doc.
  return no-apply.
END.
ON CHOOSE OF r-wrkr IN FRAME d-inv-doc
DO:
  run local-psn-chk ("wrkr", "button").
  apply "entry" to t-doc.agnt in frame d-inv-doc.
  return no-apply.
END.
on leave of t-doc.agnt in frame d-inv-doc  do:
  if not available t-doc then return .
  if input frame d-inv-doc t-doc.agnt <> t-doc.agnt then do:
    run local-psn-chk ("agnt", "leave").
  end.
end.
on leave of t-doc.boss in frame d-inv-doc   do:
  if not available t-doc then return .
  if input frame d-inv-doc t-doc.boss <> t-doc.boss then do:
    run local-psn-chk ("boss", "leave").
  end.
end.
on leave of t-doc.wrkr in frame d-inv-doc  do:
  if not available t-doc then return .
  if input frame d-inv-doc t-doc.wrkr <> t-doc.wrkr then do:
    run local-psn-chk ("wrkr", "leave").
  end.
end.
procedure local-psn-chk :
  define input parameter parman    as character no-undo.
  define input parameter paraction as character no-undo.
  if parman = "agnt" and paraction = "ret-mouse" then do:
  define variable v-ref-rec45   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-inv-doc t-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame d-inv-doc t-doc.agnt <> ""
       and input frame d-inv-doc t-doc.agnt <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec45 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-inv-doc t-doc.agnt
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ t-doc.agnt
            cli-buf.obj-name @ agnt-name with frame d-inv-doc.
    assign frame d-inv-doc t-doc.agnt.
  end.
  else display ? @ t-doc.agnt
               ? @ agnt-name with frame d-inv-doc.
  apply "entry" to t-doc.boss
                            in frame d-inv-doc.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.agnt cli-buf.obj-name @ agnt-name with frame d-inv-doc.
  end.
  else display ? @ t-doc.agnt ? @ agnt-name with frame d-inv-doc.
      return no-apply.
  end.
  if parman = "agnt" and paraction = "button" then do:
  define variable v-ref-rec46   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-inv-doc t-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec46 = ( if available cli-buf then recid( cli-buf ) else ? ).
  ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec46 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-inv-doc t-doc.agnt
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ t-doc.agnt
            cli-buf.obj-name @ agnt-name with frame d-inv-doc.
    assign frame d-inv-doc t-doc.agnt.
  end.
  else display ? @ t-doc.agnt
               ? @ agnt-name with frame d-inv-doc.
  apply "entry" to t-doc.boss
                            in frame d-inv-doc.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.agnt cli-buf.obj-name @ agnt-name with frame d-inv-doc.
  end.
  else display ? @ t-doc.agnt ? @ agnt-name with frame d-inv-doc.
      return no-apply.
  end.
  if parman = "agnt" and paraction = "leave" then do:
  define variable v-ref-rec47   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-inv-doc t-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.agnt cli-buf.obj-name @ agnt-name with frame d-inv-doc.
          assign frame d-inv-doc t-doc.agnt.
  end.
  else display ? @ t-doc.agnt ? @ agnt-name with frame d-inv-doc.
  end.
  if parman = "boss" and paraction = "ret-mouse" then do:
  define variable v-ref-rec48   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-inv-doc t-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame d-inv-doc t-doc.boss <> ""
       and input frame d-inv-doc t-doc.boss <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec48 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-inv-doc t-doc.boss
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ t-doc.boss
            cli-buf.obj-name @ boss-name with frame d-inv-doc.
    assign frame d-inv-doc t-doc.boss.
  end.
  else display ? @ t-doc.boss
               ? @ boss-name with frame d-inv-doc.
  apply "entry" to  b-exit in frame d-inv-doc.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.boss cli-buf.obj-name @ boss-name with frame d-inv-doc.
  end.
  else display ? @ t-doc.boss ? @ boss-name with frame d-inv-doc.
      return no-apply.
  end.
  if parman = "boss" and paraction = "button" then do:
  define variable v-ref-rec49   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-inv-doc t-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec49 = ( if available cli-buf then recid( cli-buf ) else ? ).
  ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec49 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-inv-doc t-doc.boss
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ t-doc.boss
            cli-buf.obj-name @ boss-name with frame d-inv-doc.
    assign frame d-inv-doc t-doc.boss.
  end.
  else display ? @ t-doc.boss
               ? @ boss-name with frame d-inv-doc.
  apply "entry" to  b-exit in frame d-inv-doc.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.boss cli-buf.obj-name @ boss-name with frame d-inv-doc.
  end.
  else display ? @ t-doc.boss ? @ boss-name with frame d-inv-doc.
      return no-apply.
  end.
  if parman = "boss" and paraction = "leave" then do:
  define variable v-ref-rec50   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-inv-doc t-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.boss cli-buf.obj-name @ boss-name with frame d-inv-doc.
          assign frame d-inv-doc t-doc.boss.
  end.
  else display ? @ t-doc.boss ? @ boss-name with frame d-inv-doc.
  end.
  if parman = "wrkr" and paraction = "ret-mouse" then do:
  define variable v-ref-rec51   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-inv-doc t-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame d-inv-doc t-doc.wrkr <> ""
       and input frame d-inv-doc t-doc.wrkr <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec51 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-inv-doc t-doc.wrkr
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ t-doc.wrkr
            cli-buf.obj-name @ wrkr-name with frame d-inv-doc.
    assign frame d-inv-doc t-doc.wrkr.
  end.
  else display ? @ t-doc.wrkr
               ? @ wrkr-name with frame d-inv-doc.
  apply "entry" to t-doc.agnt in frame d-inv-doc.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-inv-doc.
  end.
  else display ? @ t-doc.wrkr ? @ wrkr-name with frame d-inv-doc.
      return no-apply.
  end.
  if parman = "wrkr" and paraction = "button" then do:
  define variable v-ref-rec52   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-inv-doc t-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec52 = ( if available cli-buf then recid( cli-buf ) else ? ).
  ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec52 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-inv-doc t-doc.wrkr
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ t-doc.wrkr
            cli-buf.obj-name @ wrkr-name with frame d-inv-doc.
    assign frame d-inv-doc t-doc.wrkr.
  end.
  else display ? @ t-doc.wrkr
               ? @ wrkr-name with frame d-inv-doc.
  apply "entry" to t-doc.agnt in frame d-inv-doc.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-inv-doc.
  end.
  else display ? @ t-doc.wrkr ? @ wrkr-name with frame d-inv-doc.
      return no-apply.
  end.
  if parman = "wrkr" and paraction = "leave" then do:
  define variable v-ref-rec53   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-inv-doc t-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-inv-doc.
          assign frame d-inv-doc t-doc.wrkr.
  end.
  else display ? @ t-doc.wrkr ? @ wrkr-name with frame d-inv-doc.
  end.
end procedure.
procedure notes-tr:
define variable notes as character no-undo.
assign
  notes = t-doc.PS.
if pardoc-mode = 'ПРОСМОТР':U then do:
  run gbl/d-prompt.w (
      'title=Примечание\'
    + 'type=editor\'
    + 'fillin_width=96\'
    + 'fillin_height=15\'
    + 'readonly=yes\'
    , input-output notes).
end.
else do:
   run gbl/d-prompt.w (
      'title=примечание\'
    + 'type=editor\'
    + 'fillin_width=96\'
    + 'fillin_height=15\'
    , input-output notes).
    if return-value = 'false':u then return .
  if t-doc.PS <> notes then do:
  if pardoc-rec = ? then pardoc-rec = recid (t-doc).
    do transaction on error undo, return error return-value :
      find t-doc where recid (t-doc) = pardoc-rec exclusive.
      assign
        t-doc.PS = notes.
    end.
  end.
end.
end procedure.
procedure proc-exit :
  define variable v-vat-pc   as decimal no-undo .
  define variable v-slt-pc   as decimal no-undo .
  define variable v-insalepr as logical no-undo .
  assign parnext-prev = ?.
  if lookup( pardoc-mode, 'ИЗМЕНЕНИЕ':U ) > 0 or pardoc-mode = 'ДОБАВЛЕНИЕ':U then do:
    if not can-find (first ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code no-lock) and t-doc.is-flora = false then do:
      assign varlog = true .
      message "В документе нет строк, поэтому он удаляется." view-as alert-box question buttons OK-Cancel update varlog.
      if varlog = yes then do:
        if t-doc.is-flora = false then do:
            define variable varchip-code as decimal   no-undo .
                  run str/del-doc.p
                      ( input  parparentproc,
                        input  t-doc.doc-code,
                        input  v-cntxt-db-num,
                        input  "del-doc.err",
                        input  ?,
                        input  ?,
                        input  v-cntxt-userid,
                        input  t-doc.doc-code,
                        input  ?,
                        output varchip-code )
                        .
          assign pardoc-rec = ?.
          return.
        end.
        else do:
          assign varlog = false .
          message "ВНИМАНИЕ !!! Документ удалится, так как в нем НЕТ ТОВАРОВ!!!"
                     view-as alert-box  question buttons OK-Cancel update varlog .
          if varlog = yes then do:
            delete t-doc.
            assign pardoc-rec = ?.
            return.
          end.
          return error.
        end.
      end.
      else do: return error. end.
    end.
    assign frame d-inv-doc t-doc.wrkr t-doc.agnt t-doc.boss .
    define variable v-err as logical   no-undo .
    run str/ver-fl.p ( input pardoc-mode, input t-doc.doc-code , output v-err ) no-error .
    if error-status :error then return error.
  end.
  if t-doc.ext-doc-type = 'ep':U  and pardoc-mode <> 'ПРОСМОТР':U then do:
     run str/ep-corrp.p (input parparentproc , input t-doc.doc-code ) no-error.
  end.
  run fill-mol in this-procedure.
end procedure.
procedure check-base-code :
define input parameter parrec-id as recid no-undo.
define variable varmy-host-code  like ub.sysconf.host-code no-undo.
define variable varmy-base-code  like ub.sysconf.base-code no-undo.
define variable varcli-base-code like ub.sysconf.base-code no-undo.
define buffer bf-my_currency  for ub.currency.
define buffer bf-cli_currency for ub.currency.
define buffer bf_clients for ub.clients.
do on error undo, return error return-value :
  find first bf_clients where recid(bf_clients) = parrec-id no-lock.
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output varmy-host-code
  ) no-error .
  if error-status :error then do:
    message "Ошибка при поиске фирмы для объекта " v-cntxt-obj-type " " v-cntxt-obj-code " ." skip
            return-value skip
            error-status :get-message( 1 )
    view-as alert-box error.
    return no-apply.
  end.
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  varmy-host-code
  ,output varmy-base-code
  ) no-error .
  if error-status :error then do:
    message "Ошибка при поиске базовой валюты для фирмы " varmy-base-code " ." skip
            return-value skip
            error-status :get-message( 1 )
    view-as alert-box error.
    return no-apply.
  end.
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  bf_clients.obj-code
  ,output varcli-base-code
  ) no-error .
  if error-status :error then do:
    message "Ошибка при поиске базовой валюты для фирмы " bf_clients.obj-code " ." skip
            return-value skip
            error-status :get-message( 1 )
    view-as alert-box error.
    return no-apply.
  end.
  if varmy-base-code <> varcli-base-code then do:
    find first bf-my_currency  where bf-my_currency.curr-code  = varmy-base-code  no-lock.
    find first bf-cli_currency where bf-cli_currency.curr-code = varcli-base-code no-lock.
    message "Несоответствие базовых валют фирм при межфирменном перемещении." skip
            "У нашей фирмы " varmy-host-code " базовая валюта " bf-my_currency.curr-abbr " " bf-my_currency.curr-name " с кодом " bf-my_currency.curr-code " ." skip
            "У фирмы контрагента " bf_clients.obj-code " базовая валюта " bf-cli_currency.curr-abbr " " bf-cli_currency.curr-name " с кодом " bf-cli_currency.curr-code " ." skip
            "Межфирменное перемещение невозможно."
    view-as alert-box error.
    return error.
  end.
end.
end procedure.
procedure proc-history :
  define variable loc-ref-list as character no-undo.
  do on error undo, return error return-value :
    if not available ub.doc-line then do:
      message "Неправильный выбор записи." view-as alert-box.
      return error.
    end.
    run str/docclins.w ( input        parparentproc,
                     input        "":U,
                     input        "doc",
                     input        ub.doc-line.obj-type,
                     input        ub.doc-line.obj-code,
                     input        ub.doc-line.doc-code,
                     input        ub.doc-line.artic,
                     input        ub.doc-line.prod-type,
                     input        ub.doc-line.prod-code,
                     input-output loc-ref-list             ).
    apply "ENTRY":U to br-list in frame d-inv-doc.
  end.
  end procedure.
procedure fill-mol:
  if pardoc-mode = 'ИЗМЕНЕНИЕ':U or pardoc-mode = 'ДОБАВЛЕНИЕ':U
  then
  do:
    find first ub.user-account no-lock where ub.user-account.user-id = v-cntxt-userid.
    if ub.user-account.psn-code <> 0 and ub.user-account.psn-code <> ?
      then
    do:
      if t-doc.boss = ? then do:
        t-doc.boss:screen-value in frame d-inv-doc = string (ub.user-account.psn-code).
        apply "leave" to t-doc.boss in frame d-inv-doc.
      end.
      if t-doc.wrkr = ?
      then do:
        t-doc.wrkr:screen-value in frame d-inv-doc = string (ub.user-account.psn-code).
        apply "leave" to t-doc.wrkr in frame d-inv-doc.
      end.
      t-doc.agnt:screen-value in frame d-inv-doc = string (ub.user-account.psn-code).
      apply "leave" to t-doc.agnt in frame d-inv-doc.
    end.
    release ub.user-account.
  end.
end.
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref57 as character no-undo .
define variable varpgscales-pref57 as character no-undo.
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref-type58 as character no-undo.
varscales-pref57  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref57
  ,output varscales-pref-type58
  ) no-error .
if varscales-pref57 = ? then do:
  assign
  varscales-pref57 = '21,23,25':U.
end.
define variable varpgscales-pref-type58 as character no-undo.
varpgscales-pref57  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref57
  ,output varpgscales-pref-type58
  ) no-error .
if varpgscales-pref57 = ? then do:
  assign
  varpgscales-pref57 = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
on value-changed of a-n-c in frame d-inv-doc do:
  run proc-valchg-a-n-c in this-procedure  no-error.
  return no-apply.
end.
on any-printable of br-list in frame d-inv-doc do:
  run proc-any-printable-br-list in this-procedure   no-error.
  return no-apply.
end.
on backspace of br-list in frame d-inv-doc do:
  run proc-backspace-br-list in this-procedure   no-error.
  return no-apply.
end.
ON return OF loc-code IN FRAME d-inv-doc do:
  run proc-mouse-dbl-click-loc-code in this-procedure   no-error.
  return no-apply.
end.
ON return, Ctrl-J OF loc-name IN FRAME d-inv-doc do:
  run proc-mouse-dbl-click-loc-name in this-procedure   no-error.
  return no-apply.
end.
PROCEDURE proc-valchg-a-n-c:
  case input frame d-inv-doc a-n-c :
    when "art" then do:
      apply "entry" to br-list in frame d-inv-doc.
      hide loc-name loc-code
      in frame d-inv-doc.
      loc-art = "".
    end.
    when "name" then do:
      enable loc-name with frame d-inv-doc.
      disp loc-name with frame d-inv-doc.
      hide loc-art loc-code
      in frame d-inv-doc.
      apply "entry" to loc-name in frame d-inv-doc.
    end.
    when "code"
 or when "DataMatrix" then
    do:
      enable loc-code with frame d-inv-doc.
      disp loc-code with frame d-inv-doc.
      hide loc-art loc-name
      in frame d-inv-doc.
      apply "entry" to loc-code in frame d-inv-doc.
    end.
  end CASE.
END PROCEDURE.
PROCEDURE proc-any-printable-br-list :
  if input frame d-inv-doc a-n-c = "art" then do:
    if last-event:label = " " and
       loc-art = "" then
    return error.
    find first l-doc-line where
               l-doc-line.doc-code = t-doc.doc-code and l-doc-line.artic begins (loc-art + last-event:label)
               no-lock no-error.
    if available l-doc-line then do:
      loc-art = loc-art + last-event:label.
      disp loc-art with frame d-inv-doc.
      line-rec = recid (l-doc-line).
      reposition br-list to recid line-rec no-error.
    end.
  end.
END PROCEDURE.
PROCEDURE proc-backspace-br-list:
  if input frame d-inv-doc a-n-c = "art" then do:
    if loc-art = "" then
      return error.
    loc-art = substr (loc-art, 1, length (loc-art) - 1).
    find first l-doc-line where
               l-doc-line.doc-code = t-doc.doc-code and l-doc-line.artic begins loc-art
               no-lock.
    disp loc-art with frame d-inv-doc.
    line-rec = recid (l-doc-line).
    reposition br-list to recid line-rec no-error.
  end.
END PROCEDURE.
PROCEDURE proc-mouse-dbl-click-loc-code:
def var str-code as integer no-undo.
define variable varresult   as character         no-undo.
define variable vartype-bc  as character         no-undo.
define variable varweight   as decimal           no-undo.
define buffer l-goods for ub.goods.
define buffer l-bar-code for ub.bar-code.
define buffer buf_bar-code for ub.bar-code .
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_place for ub.place.
  assign
  frame d-inv-doc
  loc-code
  a-n-c.
  if a-n-c = "datamatrix"
  then do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_dm-rcnz in g#libbcrcn
(
 input  parparentproc
,input  loc-code
,input  ?
,input  v-cntxt-obj-type
,input  v-cntxt-obj-code
,input  yes
,input  no
,input  varscales-pref57
,input  varpgscales-pref57
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
     if varresult eq "prod-bc"
     then
        loc-code:screen-value in frame d-inv-doc = buf_prod-bc.b-str.
  end.
  else do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  loc-code
,input  ?
,input  v-cntxt-obj-type
,input  v-cntxt-obj-code
,input  yes
,input  no
,input  varscales-pref57
,input  varpgscales-pref57
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
end.
  if available buf_bar-code then do:
        find first l-goods where
                  l-goods.gds-code =
  buf_bar-code.gds-code No-LOCK.
        find first l-doc-line where l-doc-line.doc-code = t-doc.doc-code and
                  l-doc-line.artic = l-goods.artic AND
                  l-doc-line.prod-type = l-goods.prod-type AND
                  l-doc-line.prod-code = l-goods.prod-code no-lock no-error.
    if available l-doc-line then do:
      line-rec = recid (l-doc-line).
      reposition br-list to recid line-rec no-error.
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
    end.
  end.
  else
    message "Бар-код не найден."
            view-as alert-box error.
  apply "entry" to loc-code in frame d-inv-doc.
END PROCEDURE.
PROCEDURE  proc-mouse-dbl-click-loc-name:
  assign
  frame d-inv-doc
  loc-name.
    if last-event:label = "Ctrl-J" then
      find next l-doc-line where l-doc-line.doc-code = t-doc.doc-code and
                can-find (ub.goods where ub.goods.artic = l-doc-line.artic and
                ub.goods.prod-type = l-doc-line.prod-type and
                ub.goods.prod-code = l-doc-line.prod-code and
                ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    else
      find first l-doc-line where l-doc-line.doc-code = t-doc.doc-code and
                can-find (ub.goods where ub.goods.artic = l-doc-line.artic and
                ub.goods.prod-type = l-doc-line.prod-type and
                ub.goods.prod-code = l-doc-line.prod-code and
                ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    if available l-doc-line then do:
      line-rec = recid (l-doc-line).
      reposition br-list to recid line-rec no-error.
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
    end.
  apply "entry" to loc-name in frame d-inv-doc.
END PROCEDURE.
on value-changed of br-list in frame d-inv-doc do:
if not available ub.doc-line or recid (ub.doc-line) <> line-rec then do:
    hide loc-art in frame d-inv-doc.
    loc-art = "".
end.
end.
ON CHOOSE OF MENU-ITEM m_lookup
DO:
  define buffer buf_utd-marking-lines for ub.utd-marking-lines.
  define buffer buf_marking for ub.marking.
  if available (t-doc) then do:
      for each ub.marking-attr no-lock where
            ub.marking-attr.attr-value = t-doc.doc-code
        and (ub.marking-attr.attr-code = "inv-doc" or ub.marking-attr.attr-code = "inv-doc-scan"):
      for each ub.marking-lines no-lock where
        ub.marking-lines.obj-type = t-doc.obj-type
        and ub.marking-lines.obj-code = t-doc.obj-code
        and ub.marking-lines.out-code = 'free-zone':U
        and ub.marking-lines.mark = ub.marking-attr.mark
        :
        find first ub.marking no-lock where ub.marking.mark = ub.marking-lines.mark and ub.marking.sts <> ObjSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB no-error.
        if available (ub.marking)
          then
        do:
          create tt-marking-lines.
          buffer-copy ub.marking-lines to tt-marking-lines.
          tt-marking-lines.sts = ub.marking.sts.
          tt-marking-lines.stts = objSrv:Env:Marking:Sts:Mark:GetLabel(ub.marking.sts).
          tt-marking-lines.sts-utd = ub.marking-lines.sts.
          tt-marking-lines.stts-utd = objSrv:Env:Marking:Sts:Mark:Checked_:Label_.
          tt-marking-lines.box-qnty = ub.marking.box-qnty .
          tt-marking-lines.unit = ub.marking.unit .
          tt-marking-lines.unit-ext = ub.marking.unit-ext .
          if ub.marking-attr.attr-code = "inv-doc-scan"
            then tt-marking-lines.doc-level = 1.
            else tt-marking-lines.doc-level = 2.
          tt-marking-lines.mark-parent = ub.marking.mark-parent.
          tt-marking-lines.out-code = t-doc.doc-code.
        end.
      end.
    end.
    for each ub.utd no-lock where
            ub.utd.doc-code = t-doc.doc-code
        :
      for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = ub.utd.db-num and buf_utd-marking-lines.doc-id = ub.utd.doc-id and buf_utd-marking-lines.mark <> "",
        each buf_marking no-lock where buf_marking.mark = buf_utd-marking-lines.mark:
        find first ub.goods where buf_marking.gds-code = ub.goods.gds-code.
        create tt-marking-lines .
        assign
          tt-marking-lines.gds-name    = ub.goods.gds-name
          tt-marking-lines.stts-utd    = objSrv:Env:Marking:Sts:Mark:GetLabel(buf_utd-marking-lines.sts)
          tt-marking-lines.stts        = objSrv:Env:Marking:Sts:Mark:GetLabel(buf_marking.sts)
          tt-marking-lines.mark        = buf_marking.mark
          tt-marking-lines.mark-parent = buf_marking.mark-parent
          tt-marking-lines.gds-code    = buf_utd-marking-lines.gds-code
          tt-marking-lines.sts         = buf_marking.sts
          tt-marking-lines.sts-utd     = buf_utd-marking-lines.sts
          tt-marking-lines.unit        = buf_marking.unit
          tt-marking-lines.unit-ext    = buf_marking.unit-ext
          tt-marking-lines.box-qnty    = buf_marking.box-qnty
          tt-marking-lines.LineNum     = buf_utd-marking-lines.LineNum
          tt-marking-lines.db-num      = buf_utd-marking-lines.db-num
          tt-marking-lines.doc-id      = buf_utd-marking-lines.doc-id
          tt-marking-lines.doc-level   = buf_utd-marking-lines.doc-level
          .
      end.
    end.
    if can-find (first tt-marking-lines no-lock) then
    do:
      run str/mark_browse.w (input parparentproc,
        input-output table tt-marking-lines by-reference,
        input 'ПРОСМОТР':U,
        input "Марки по документу: " + t-doc.doc-code,
        input "0",
        input ""
        )  .
      for each tt-marking-lines:
        delete tt-marking-lines.
      end.
    end.
    else do:
      message "Марки не найдены." view-as alert-box information title "Информация".
    end.
  end.
END.
ON CHOOSE OF MENU-ITEM m_introduce-marks
DO:
  if v-is-introduce then do:
    message "Флаг уже установлен." view-as alert-box information.
    return no-apply.
  end.
  find first ub.doc-line no-lock where ub.doc-line.doc-code = t-doc.doc-code no-error.
  if available (ub.doc-line)
  then do:
    message "В инвентаризации присутсвуют товары. Невозможно установить флаг." view-as alert-box information.
    return no-apply.
  end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'trdcattr-inv-introduce':U ,
                       input yes ) no-error .
  if error-status:error
  then do:
    message "Ошибка установки флага. " + return-value view-as alert-box error.
    return no-apply.
  end.
  def var introdUtd as class introduce no-undo.
  introdUtd = new introduce() no-error.
  if not valid-object (introdUtd)
  then do:
    message "Ошибка создания объекта introdUtd. " + return-value view-as alert-box error.
    return no-apply.
  end.
  v-is-introduce = true.
  def var v-utd-num as character no-undo.
  v-utd-num = introdUtd:CrUTDIntroduce(t-doc.doc-code).
  delete object introdUtd.
  run ui-on in this-procedure ( input "all" ).
  message "Флаг установлен. Создан документ первоначального ввода № " + v-utd-num view-as alert-box information.
END.
on choose of b-alcmark in frame d-inv-doc do:
  run str/inv-marks.w (parparentproc, t-doc.doc-code, ?).
  find first ub.doc-line no-lock where recid( ub.doc-line ) = line-rec no-error.
  if available ub.doc-line then do:
    display fncgele( buffer ub.doc-line )   @ inv-mark              column-label 'К' format "x(1)":U  if ub.doc-line.prt-OK then '*' else ''   @ prt-mark              column-label 'Ш' format "x(1)":U  ub.doc-line.artic                           column-label 'Артикул'  ub.goods.gds-name                           column-label 'Имя ' format "x(150)":U  fncdiffqntykg( buffer ub.doc-line )  @ vardiff-qnty-kg       column-label 'Разница, кг' format "->>>,>>>,>>9.999":U  markqnty( buffer ub.doc-line )  @ var-qnty-mark         column-label 'Кол-во марок' format ">>>>9":U  markqntycheckinv( buffer ub.doc-line )  @ var-qnty-mark-chk     column-label 'Проверено марок' format ">>>>9":U  markqntytech( buffer ub.doc-line )  @ var-qnty-mark-tech    column-label 'Тех. марки' format ">>>>9":U  fncwasqntykg( buffer ub.doc-line )  @ varwas-qnty-kg        column-label 'Было, кг' format "->>>,>>>,>>9.999":U  fncareqntykg( buffer ub.doc-line )  @ varare-qnty-kg        column-label 'Стало, кг' format "->>>,>>>,>>9.999":U  fncdiffqntykg( buffer ub.doc-line )  @ vardiff-qnty-kg       column-label 'Разница, кг' format "->>>,>>>,>>9.999":U  ub.doc-line.doc-qnty - ub.doc-line.fact-qnty   @ varbefore-qnty        column-label 'Было'  wasQuant(ub.doc-line.doc-qnty, invTSD)   @ vdoc-qnty             column-label 'Стало'  ub.doc-line.fact-qnty                           column-label 'Разница'  ub.doc-line.vat-pc                          column-label 'НДС' format ">9.9%":U  ub.goods.unit-base                           column-label 'Ед. изм.'  fncextra-qnty( buffer ub.doc-line )  @ varextra-qnty         column-label 'Излишки'  fncmiss-qnty( buffer ub.doc-line )  @ varmiss-qnty          column-label 'Недостача'  fncbefore-base( buffer ub.doc-line, buffer ub.goods )  @ varbefore-base        column-label 'Было! учет цены(вал)'  fncbefore-rubl( buffer ub.doc-line, buffer ub.goods )  @ varbefore-rubl        column-label 'Было! учет цены(руб)'  fncafter-base( buffer ub.doc-line, buffer ub.goods )  @ varafter-base         column-label 'Стало! учет цены(вал)'  fncafter-rubl( buffer ub.doc-line, buffer ub.goods )  @ varafter-rubl         column-label 'Стало! учет цены(руб)'  fncextra-base( buffer ub.doc-line, buffer ub.goods )  @ varextra-base         column-label 'Излишки! учет цены(вал)'  fncextra-rubl( buffer ub.doc-line, buffer ub.goods )  @ varextra-rubl         column-label 'Излишки! учет цены(руб)'  fncmiss-base( buffer ub.doc-line, buffer ub.goods )  @ varmiss-base          column-label 'Недостача! учет цены(вал)'  fncmiss-rubl( buffer ub.doc-line, buffer ub.goods )  @ varmiss-rubl          column-label 'Недостача! учет цены(руб)'  fncbefore-rb( buffer ub.doc-line, buffer ub.goods )  @ varbefore-rb          column-label 'Было! прод цены'  fncafter-rb( buffer ub.doc-line, buffer ub.goods )  @ varafter-rb           column-label 'Стало! прод цены'  fncextra-rb( buffer ub.doc-line, buffer ub.goods )  @ varextra-rb           column-label 'Излишки! прод цены'  fncmiss-rb( buffer ub.doc-line, buffer ub.goods )  @ varmiss-rb            column-label 'Недостача! прод цены'  fncmiss-without-wastage( buffer ub.doc-line, buffer ub.goods )  @ varmiss-without-wast  column-label 'Нед. без ест. уб.! прод цены'  fncwastage( buffer ub.doc-line, buffer ub.goods )  @ varwastage            column-label 'Ест. убыль! прод цены'  fncwast-rb( buffer ub.doc-line, buffer ub.goods )  @ varwast-rb            column-label 'Фонд. ест. убыли! прод цены'  fncunus-wast-rb( buffer ub.doc-line, buffer ub.goods )  @ varunus-wast-rb       column-label 'Неизр. ест. убыль! прод цены'  ub.goods.gds-code                          column-label 'Код товара' FORMAT "99999999999":U  ub.doc-line.inv-peresort-qnty                          column-label 'Пересортица' format "->>>,>>>,>>9.999":U  fncnode-name( buffer ub.doc-line, buffer ub.goods )   @ scl-name              column-label 'Шкала' format "x(10)":U with browse br-list.
  end.
  run ui-on in this-procedure ( input "" ).
end.
ON CHOOSE OF MENU-ITEM m_add-marks
DO:
  def var v-mode as char no-undo.
  if not can-find(first ub.doc-line no-lock where ub.doc-line.doc-code = t-doc.doc-code)
  then do:
    message "В документе нет строк." view-as alert-box information.
    return no-apply.
  end.
  if not v-is-introduce and not v-is-marking
  then do:
    message "Не включен помарочный учет либо первоначальный ввод." view-as alert-box information.
    return no-apply.
  end.
  if v-is-introduce
    then v-mode = "introduce".
  run str/chs-marks.w (parparentproc, t-doc.doc-code, v-mode, this-procedure).
  run UI-on in this-procedure ( input "":U ).
END.
ON CHOOSE OF MENU-ITEM m_introduce-marks
DO:
  if v-is-introduce then do:
    message "Флаг уже установлен." view-as alert-box information.
    return no-apply.
  end.
  find first ub.doc-line no-lock where ub.doc-line.doc-code = t-doc.doc-code no-error.
  if available (ub.doc-line)
  then do:
    message "В инвентаризации присутсвуют товары. Невозможно установить флаг." view-as alert-box information.
    return no-apply.
  end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'trdcattr-inv-introduce':U ,
                       input yes ) no-error .
  if error-status:error
  then do:
    message "Ошибка установки флага. " + return-value view-as alert-box error.
    return no-apply.
  end.
  def var introdUtd as class introduce no-undo.
  introdUtd = new introduce() no-error.
  if not valid-object (introdUtd)
  then do:
    message "Ошибка создания объекта introdUtd. " + return-value view-as alert-box error.
    return no-apply.
  end.
  v-is-introduce = true.
  def var v-utd-num as character no-undo.
  v-utd-num = introdUtd:CrUTDIntroduce(t-doc.doc-code).
  delete object introdUtd.
  run ui-on in this-procedure ( input "all" ).
  message "Флаг установлен. Создан документ первоначального ввода № " + v-utd-num view-as alert-box information.
END.
on choose of b-inv-prsrt in frame d-inv-doc
do:
define buffer buf_doc-line for ub.doc-line  .
define variable v-gds-code  as integer   no-undo .
define variable v-sum1 as decimal   no-undo .
define variable v-sum2 as decimal   no-undo .
define variable v-sum3 as decimal   no-undo .
v-sum1 = 0 .
v-sum2 = 0 .
v-sum3 = 0 .
  for each buf_doc-line no-lock where
           buf_doc-line.doc-code = t-doc.doc-code
           :
         if buf_doc-line.inv-peresort > 0 then v-sum1 = v-sum1 + buf_doc-line.inv-peresort .
         if buf_doc-line.inv-peresort < 0 then v-sum2 = v-sum2 + abs(buf_doc-line.inv-peresort) .
  end.
  message
  'По пересортице + :'   v-sum1 skip
  'По пересортице  - : ' v-sum2 skip
  'Не распределено  : ' v-sum2 - v-sum1  skip
  view-as alert-box information .
end.
ON value-changed OF t-othermoves IN FRAME d-inv-doc DO:
  assign t-othermoves .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'othermoves':U ,
                       input string(t-othermoves) ) no-error .
END.
ON value-changed OF dif-only IN FRAME d-inv-doc DO:
  assign dif-only = input frame d-inv-doc dif-only
         line-rec = ?.
  run UI-on in this-procedure ( input "":U ).
END.
on value-changed of varinvclcwtol in frame d-inv-doc do:
  if input frame d-inv-doc varinvclcwtol <> varinvclcwtol then do:
    run local-chg-wtol in this-procedure.
  end.
end.
on value-changed of varinvclcasol in frame d-inv-doc do:
  if input frame d-inv-doc varinvclcasol <> varinvclcasol then do:
    run local-chg-asol in this-procedure no-error.
    if error-status :error then do:
      return no-apply.
    end.
  end.
  run ui-on in this-procedure ( input "":U ).
end.
on choose of b-unscn do:
  run str/scn-inv.w
     ( input parparentproc,
       input ( if pardoc-mode <> 'ПРОСМОТР':U then recid(t-doc) else ? )
       ).
      if t-doc.status_ = 'разрешен':U and pardoc-mode = 'ИЗМЕНЕНИЕ':U then do:
        run full-recalc in this-procedure.
      end.
    run UI-on in this-procedure ( input "":U ).
end.
on choose of b-add in frame d-inv-doc
do:
  run local-add in this-procedure
    no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при добавлении строки инвентаризации") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return no-apply .
  end.
end.
on choose of b-arch in frame d-inv-doc
do:
  run str/docsuppn.w
    (input  parparentproc
    ,input  recid( t-doc )
    ).
end.
on choose of b-cnt in frame d-inv-doc
do:
  run str/inv-cnt.p ( input parparentproc, input t-doc.doc-code ).
end.
on choose of menu-item m-clr-1 do:
  run m-clr-1 in this-procedure.
end.
on choose of menu-item m-clr-2 do:
  run m-clr-2 in this-procedure.
end.
on choose of menu-item m-clr-3 do:
  run m-clr-3 in this-procedure.
end.
on choose of menu-item m-st-1 do:
  run m-st-1 in this-procedure.
  run ui-on  in this-procedure ( input "":U ).
end.
on choose of menu-item m-st-2 do:
  run m-st-2 in this-procedure.
  run ui-on  in this-procedure ( input "":U ).
end.
on choose of menu-item m-st-3 do:
  run m-st-3 in this-procedure.
  run ui-on  in this-procedure ( input "":U ).
end.
on choose of menu-item m-parts-1
do:
  apply "row-leave":U to browse br-list.
  run m-parts-1 in this-procedure.
end.
on choose of menu-item m-parts-2
do:
  apply "row-leave":U to browse br-list.
  run m-parts-2 in this-procedure.
end.
ON choose OF MENU-ITEM m-chk-doc-add in menu m-chk-doc DO:
  assign
  chk-doc-option = 'ДОБАВЛЕНИЕ':U.
  apply "choose" to b-chk-doc in frame d-inv-doc .
END.
ON choose OF MENU-ITEM m-chk-docs in menu m-chk-doc DO:
  assign
  chk-doc-option = 'ПРОСМОТР':U.
  apply "choose" to b-chk-doc in frame d-inv-doc .
END.
ON choose OF MENU-ITEM m-chk-gds in menu m-chk-doc DO:
  assign
  chk-doc-option = "chk-gds".
  apply "choose" to b-chk-doc in frame d-inv-doc .
END.
on choose of b-del in frame d-inv-doc
do:
  run local-delete in this-procedure
    no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при удалении строки инвентаризации") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return no-apply .
  end.
end.
on choose of b-chg in frame d-inv-doc
do:
  run local-chg in this-procedure
    no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при изменении строки инвентаризации") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return no-apply .
  end.
end.
on choose of b-lkp in frame d-inv-doc
do:
  if not available ub.doc-line then do:
    message "Неправильный выбор строки." view-as alert-box.
    return no-apply .
  end.
  run str/inv-lkp.p
    ( input parparentproc
    , input ub.doc-line.doc-code
    , input ub.doc-line.artic
    , input ub.doc-line.prod-type
    , input ub.doc-line.prod-code
    ) .
  apply "entry":U to br-list in frame d-inv-doc.
end.
on choose of b-updprt- in frame d-inv-doc
do:
  run local-updprt- in this-procedure.
end.
on choose of b-parts in frame d-inv-doc
do:
  run local-parts in this-procedure.
end.
on value-changed of invTSD in frame d-inv-doc
  do:
    define buffer buf_inv-doc-attr for ub.inv-doc-attr .
    assign invTSD .
    find first buf_inv-doc-attr exclusive-lock where buf_inv-doc-attr.doc-code = t-doc.doc-code and
      buf_inv-doc-attr.attr-code = 'invMultDevice' no-error .
    if invTSD then
    do:
      if available (buf_inv-doc-attr) then buf_inv-doc-attr.attr-value = string(invTSD) .
      else
      do:
        create buf_inv-doc-attr .
        assign
          buf_inv-doc-attr.doc-code   = t-doc.doc-code
          buf_inv-doc-attr.attr-code  = 'invMultDevice'
          buf_inv-doc-attr.attr-value = string(invTSD)
          .
      end.
    end.
    else
    do:
      if available (buf_inv-doc-attr) then delete buf_inv-doc-attr .
    end.
run UI-on-browse in this-procedure ( input "":U ) no-error.
end.
ON CHOOSE OF b-attr IN FRAME d-inv-doc
DO:
  run init-attr-general in this-procedure .
    if t-doc.status_ <> 'факт':U then do:
      run str/inv-attr.w (input ParParentproc, input "b-lkp,b-chg", input t-doc.doc-code, input table tt-upd-attr) no-error.
    end.
    else do:
      run str/inv-attr.w (input ParParentproc, input "b-lkp", input t-doc.doc-code, input table tt-upd-attr) no-error.
    end.
END.
on choose of b-chk-doc in frame d-inv-doc
do:
define variable loc-chk-doc-option as character no-undo .
  if chk-doc-option = '':U then do:
    run gbl/pop-up.p ( input b-chk-doc:handle, input no) no-error.
  end.
  if chk-doc-option = '':U then return no-apply.
  assign
  loc-chk-doc-option = chk-doc-option
  chk-doc-option = '':U
  .
  run local-chk-doc in this-procedure ( input loc-chk-doc-option) no-error.
  if error-status:error then return no-apply.
end.
on choose of b-list in frame d-inv-doc
do:
  run local-list in this-procedure.
end.
on return, mouse-select-dblclick of br-list in frame d-inv-doc
do:
  if b-chg :sensitive = yes then do:
    apply "choose":U to b-chg in frame d-inv-doc.
  end.
  else do:
    apply "choose":U to b-lkp in frame d-inv-doc.
  end.
END.
on choose of b-sum-doc in frame d-inv-doc do:
  run str/vsumtype.w ( input yes, input t-doc.doc-code, input ? ).
end.
on choose of b-sum-goods in frame d-inv-doc do:
  if available ub.goods then do:
    run str/vsumtype.w ( input no, input t-doc.doc-code, input ub.goods.gds-code ).
  end.
end.
on leave of t-doc.reason-code in frame d-inv-doc do:
  run check-reason in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.
on return of t-doc.reason-code in frame d-inv-doc do:
  run check-reason in this-procedure no-error .
  if error-status :error then do: return no-apply. end.
end.
on choose of r-reas in frame d-inv-doc do:
  run select-reason in this-procedure.
end.
on leave of t-doc.fact-date in frame d-inv-doc
do:
  run chk-upd-date in this-procedure ( input self :name ).
end.
on return of t-doc.fact-date in frame d-inv-doc
do:
  if t-doc.fact-date:sensitive in frame d-inv-doc then do:
    apply "entry" to t-doc.shift-date in frame d-inv-doc.
  end.
  else do:
    apply "entry" to b-add in frame d-inv-doc.
  end.
  return no-apply.
end.
ON LEAVE OF t-doc.shift-date IN FRAME d-inv-doc
do:
  if input frame d-inv-doc t-doc.shift-date <> t-doc.shift-date then do:
    assign
      t-doc.shift-name = ""
      t-doc.shift-num  = 0.
    display t-doc.shift-name t-doc.shift-num with frame d-inv-doc.
    apply "entry" to t-doc.shift-name in frame d-inv-doc.
    return no-apply.
  end.
end.
on return of t-doc.shift-date in frame d-inv-doc do:
  apply "entry" to t-doc.shift-name in frame d-inv-doc.
  return no-apply.
end.
on return of t-doc.shift-name in frame d-inv-doc do:
  apply "entry" to b-add in frame d-inv-doc.
  return no-apply.
end.
on return of t-doc.shift-num in frame d-inv-doc do:
  apply "entry" to b-add in frame d-inv-doc.
  return no-apply.
end.
on choose of r-sht in frame d-inv-doc do:
  run proc-sht.
end.
on leave of t-doc.shift-num  in frame d-inv-doc do:
  run proc-shift-num no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.
on leave of t-doc.shift-name in frame d-inv-doc do:
  run proc-shift-name no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.
ON row-display OF br-list IN FRAME d-inv-doc
DO:
  if not ((v-is-introduce or v-is-marking) and (t-doc.status_ = 'накл':U))
    then return.
  if doc-line.doc-qnty - doc-line.fact-qnty ne markqntycheckinv( buffer ub.doc-line ) + markqntytech( buffer ub.doc-line )
  then do ii = 1 to extent (bcol):
    if valid-handle (bcol[ii])
    then do:
      assign
        bcol[ii]:bgcolor = RED_COLOR.
    end.
  end.
END.
if valid-handle( active-window ) and frame d-inv-doc :parent eq ?
then frame d-inv-doc :parent = active-window.
on window-close of frame d-inv-doc do:
  apply "end-error":U to self.
end.
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of t-doc.fact-date in frame d-inv-doc
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of t-doc.fact-date in frame d-inv-doc
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of t-doc.fact-date in frame d-inv-doc
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of t-doc.fact-date in frame d-inv-doc
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of t-doc.fact-date in frame d-inv-doc
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of t-doc.fact-date in frame d-inv-doc
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date60
    MENU-ITEM m-ed-date60-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date60-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date60-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date60-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if t-doc.fact-date :POPUP-MENU in frame d-inv-doc = ?
  then do:
    ASSIGN
      t-doc.fact-date :POPUP-MENU in frame d-inv-doc = MENU m-ed-date60 :HANDLE
      t-doc.fact-date :MENU-MOUSE in frame d-inv-doc = 3
    .
  end.
  define variable v-label-handle60 as handle no-undo .
  assign
    v-label-handle60 = t-doc.fact-date :side-label-handle in frame d-inv-doc
  .
  if valid-handle (v-label-handle60)
  then do:
    if v-label-handle60 :tooltip = ""
    or v-label-handle60 :tooltip = ?
    then do:
      assign
        v-label-handle60 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date60-1 in menu m-ed-date60 DO:
    apply "ctrl-b":U to t-doc.fact-date in frame d-inv-doc .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date60-2 in menu m-ed-date60 DO:
    apply "ctrl-d":U to t-doc.fact-date in frame d-inv-doc .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date60-3 in menu m-ed-date60 DO:
    apply "ctrl-e":U to t-doc.fact-date in frame d-inv-doc .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date60-4 in menu m-ed-date60 DO:
    apply "ctrl-f":U to t-doc.fact-date in frame d-inv-doc .
  END.
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of t-doc.shift-date in frame d-inv-doc
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of t-doc.shift-date in frame d-inv-doc
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of t-doc.shift-date in frame d-inv-doc
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of t-doc.shift-date in frame d-inv-doc
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of t-doc.shift-date in frame d-inv-doc
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of t-doc.shift-date in frame d-inv-doc
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date62
    MENU-ITEM m-ed-date62-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date62-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date62-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date62-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if t-doc.shift-date :POPUP-MENU in frame d-inv-doc = ?
  then do:
    ASSIGN
      t-doc.shift-date :POPUP-MENU in frame d-inv-doc = MENU m-ed-date62 :HANDLE
      t-doc.shift-date :MENU-MOUSE in frame d-inv-doc = 3
    .
  end.
  define variable v-label-handle62 as handle no-undo .
  assign
    v-label-handle62 = t-doc.shift-date :side-label-handle in frame d-inv-doc
  .
  if valid-handle (v-label-handle62)
  then do:
    if v-label-handle62 :tooltip = ""
    or v-label-handle62 :tooltip = ?
    then do:
      assign
        v-label-handle62 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date62-1 in menu m-ed-date62 DO:
    apply "ctrl-b":U to t-doc.shift-date in frame d-inv-doc .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date62-2 in menu m-ed-date62 DO:
    apply "ctrl-d":U to t-doc.shift-date in frame d-inv-doc .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date62-3 in menu m-ed-date62 DO:
    apply "ctrl-e":U to t-doc.shift-date in frame d-inv-doc .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date62-4 in menu m-ed-date62 DO:
    apply "ctrl-f":U to t-doc.shift-date in frame d-inv-doc .
  END.
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-inv-doc
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
on choose of b-help in frame d-inv-doc
do:
  apply "help":u to frame d-inv-doc .
end.
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-inv-doc:width - 0.3
                fh            = frame d-inv-doc:first-child
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
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame d-inv-doc :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-inv-doc :height-chars)
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
    if frame d-inv-doc :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-inv-doc :height-chars)
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
            frame d-inv-doc :height = v-frame-height
          .
          if frame d-inv-doc :scrollable = true
          then do:
            assign
              frame d-inv-doc :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-inv-doc :scrollable = true
          then do:
            assign
              frame d-inv-doc :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-inv-doc :height = v-frame-height
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
      v-frame-height = frame d-inv-doc :height
      v-frame-virtual-height = frame d-inv-doc :virtual-height
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
      v-field-group-handle = frame d-inv-doc :first-child
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
    do with frame d-inv-doc
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-inv-doc :scrollable = true
      then do:
        assign
          frame d-inv-doc :virtual-height = frame d-inv-doc :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-inv-doc :height = frame d-inv-doc :height + p-change-value
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
        frame d-inv-doc :height = frame d-inv-doc :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-inv-doc :scrollable = true
      then do:
        assign
          frame d-inv-doc :virtual-height = frame d-inv-doc :virtual-height + p-change-value
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
          ,input  string(frame d-inv-doc :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame d-inv-doc :height)
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
    if frame d-inv-doc :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-inv-doc :width
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
    if frame d-inv-doc :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-inv-doc :width
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
            frame d-inv-doc :width = v-frame-width
          .
          if frame d-inv-doc :scrollable = true
          then do:
            assign
              frame d-inv-doc :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-inv-doc :scrollable = true
          then do:
            assign
              frame d-inv-doc :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-inv-doc :width = v-frame-width
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
      v-frame-width = frame d-inv-doc :width
      v-frame-virtual-width = frame d-inv-doc :virtual-width
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
      v-field-group-handle = frame d-inv-doc :first-child
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
    do with frame d-inv-doc
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-inv-doc :scrollable = true
      then do:
        assign
          frame d-inv-doc :virtual-width = frame d-inv-doc :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-inv-doc :width = v-frame-width + p-change-value
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
        frame d-inv-doc :width = frame d-inv-doc :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-inv-doc :scrollable = true
      then do:
        assign
          frame d-inv-doc :virtual-width = frame d-inv-doc :virtual-width + p-change-value
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
          ,input  string(frame d-inv-doc :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame d-inv-doc :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-inv-doc
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-inv-doc :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-inv-doc :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-inv-doc :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-inv-doc :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame d-inv-doc
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
      v-row-delta = v-new-row - frame d-inv-doc :height
      v-col-delta = v-new-col - frame d-inv-doc :width
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
            - frame d-inv-doc :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-inv-doc :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-inv-doc :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-inv-doc :height-chars
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
      v-diasize-current-frame-width  = frame d-inv-doc :width
      v-diasize-current-frame-height = frame d-inv-doc :height
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
    do with frame d-inv-doc
    :
      assign
        v-diasize-orig-frame-height = frame d-inv-doc :height
        v-diasize-orig-frame-width  = frame d-inv-doc :width
        v-diasize-browse-handle     = browse br-list :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-inv-doc :first-child
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
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.
assign
  fi-rub-header = " РУБ "
.
assign
  parnext-prev = yes
.
n-p:
do while parnext-prev :
  main-block:
  do on error   undo main-block, leave main-block
     on end-key undo main-block, leave main-block :
    assign
       br-list:column-resizable in frame d-inv-doc = true.
    if pardoc-mode = 'ДОБАВЛЕНИЕ':U then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_adinvdoc in g#lib-trn3
(input  v-cntxt-obj-type
,input  v-cntxt-obj-code
,input  v-cntxt-userid
,output pardoc-rec
) no-error.
      if error-status :error then do:
        assign
          parnext-prev = no.
        return error.
      end.
      find first t-doc where recid( t-doc ) = pardoc-rec.
    end.
    else do:
      if pardoc-mode = 'ПРОСМОТР':U then  find first t-doc NO-LOCK where recid( t-doc ) = pardoc-rec no-error.
      else find first t-doc where recid( t-doc ) = pardoc-rec no-error.
      if available t-doc then do:
        if pardoc-mode = 'ИЗМЕНЕНИЕ':U then do:
          case t-doc.status_ :
            when 'накл':U then do:
              if t-doc.flag_ then do:
                message "Опись инвентаризации закрыта." skip (2)
                        "Редактирование невозможно."
                        view-as alert-box error.
                assign
                  parnext-prev = no.
                return error.
              end.
            end.
            when 'разрешен':U then do:
              if v-cntxt-db-num-obj <> 0 and  v-cntxt-db-num-obj <> v-cntxt-db-num then do:
                message "Документ  №" t-doc.doc-code skip (2)
                        "Редактирование возможно только на активной стороне."
                        view-as alert-box error.
                assign
                  parnext-prev = no.
                return error.
              end.
            end.
            otherwise do:
              assign
                parnext-prev = no.
              return error.
            end.
          end case.
        run ver-price .
        end.
      end.
      else do:
        assign
          parnext-prev = no.
        return error "Неправильный выбор документа.".
      end.
    end.
    assign
      varinvclcspvalue = "no"
    .
    def var v-attr-value as character no-undo.
    def var v-attr-type as character no-undo.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'trdcattr-inv-introduce':U ,
                       output v-attr-value ,
                       output v-attr-type ) no-error .
    if not error-status:error and v-attr-value = "yes" then do:
      v-is-introduce = true.
    end.
    run str/invdcfrd.p (  input t-doc.doc-code,
                     output varinvclcspvalue,
                     output prtvalue,
                     output varr-b ,
                     output is-cdinv
                     ) no-error.
    if error-status :error then do:
      assign
        parnext-prev = no.
      return error.
    end.
    if pardoc-mode <> 'ПРОСМОТР':U then do:
      assign
        line-rec = ?
      .
    end.
    assign
      dif-only = "all":U
    .
    ub.goods.gds-name:width     in browse br-list   = 40.
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-list as INT EXTENT 29 no-undo.
DEF VAR varmvibr-list       as INT no-undo.
DEF VAR varmvjbr-list       as INT no-undo.
DEF VAR varmvkbr-list       as INT no-undo.
DEF VAR varmvlbr-list       as INT no-undo.
DEF VAR move-elementbr-list as INT no-undo.
def var jjbr-list           as int no-undo.
do varmvibr-list = 1 to EXTENT(cur-clmn-numbr-list):
  ASSIGN cur-clmn-numbr-list[varmvibr-list] = varmvibr-list.
END.
RUN start-mv-clmnbr-list.
PROCEDURE start-mv-clmnbr-list:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-list do:
  RUN re-move-clmnbr-list ( 3 + 1, 29).
END.
ON ctrl-cursor-left OF BROWSE br-list do:
  RUN re-move-clmnbr-list (29, 3 + 1).
END.
PROCEDURE re-move-clmnbr-list:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-list = 1 TO EXTENT(cur-clmn-numbr-list):
    if cur-clmn-numbr-list[varmvibr-list] = source-column THEN cur-clmn-numbr-list[varmvibr-list] = -1.
  END.
  if br-list:MOVE-COLUMN(source-column, target-column) IN FRAME d-inv-doc then.
  if source-column > target-column THEN
  DO varmvjbr-list = source-column - 1 to target-column BY -1:
    DO varmvibr-list = 1 TO EXTENT(cur-clmn-numbr-list):
        if cur-clmn-numbr-list[varmvibr-list] = varmvjbr-list THEN DO:
          cur-clmn-numbr-list[varmvibr-list] = cur-clmn-numbr-list[varmvibr-list] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-list = source-column + 1 to target-column:
    DO varmvibr-list = 1 TO EXTENT(cur-clmn-numbr-list):
      if cur-clmn-numbr-list[varmvibr-list] = varmvjbr-list THEN DO:
        cur-clmn-numbr-list[varmvibr-list] = cur-clmn-numbr-list[varmvibr-list] - 1.
      END.
    END.
  END.
  DO varmvibr-list = 1 TO EXTENT(cur-clmn-numbr-list):
    if cur-clmn-numbr-list[varmvibr-list] = -1 THEN cur-clmn-numbr-list[varmvibr-list] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-list:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 3 + 1 then do:
    return .
  end.
  DO varmvibr-list = 1 TO EXTENT(cur-clmn-numbr-list):
    if cur-clmn-numbr-list[varmvibr-list] = cur-clmn-loc THEN move-elementbr-list = varmvibr-list.
  END.
  RUN re-move-clmnbr-list (cur-clmn-loc, 3 + 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-list:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-list = 3 + 1 to EXTENT(cur-clmn-numbr-list):
    RUN re-move-clmnbr-list (cur-clmn-numbr-list[varmvlbr-list], varmvlbr-list).
  END.
  RUN start-mv-clmnbr-list.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
    find first bf_sysconf where bf_sysconf.host-code = t-doc.host-code no-lock.
    run UI-on in this-procedure ( input "":U ) no-error.
    if error-status :error then do:
      assign
        parnext-prev = no.
      return error.
    end.
    run fill-mol.
    WAIT-FOR GO OF FRAME d-inv-doc FOCUS br-list.
  end.
end.
hide frame d-inv-doc no-pause.
procedure ui-on :
define input parameter parmode as character no-undo .
define variable varadd-back-date        as   logical               no-undo.
define buffer bf-ext_trn-doc-sum for ub.trn-doc-sum.
define buffer bf-mis_trn-doc-sum for ub.trn-doc-sum.
define buffer bf-wt_trn-doc-sum  for ub.trn-doc-sum.
define buffer bf-uwt_trn-doc-sum for ub.trn-doc-sum.
define buffer bf_trn-reason      for ub.trn-reason.
define variable p-value as character no-undo.
define variable p-type  as character no-undo.
define buffer bf_inv-doc-attr for ub.inv-doc-attr .
  find first ub.doc-line no-lock where ub.doc-line.doc-code = t-doc.doc-code no-error.
  if available (ub.doc-line)
  then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input ub.doc-line.artic
  ,  input ub.doc-line.prod-type
  ,  input ub.doc-line.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
  end.
    find first bf_inv-doc-attr no-lock where bf_inv-doc-attr.doc-code = t-doc.doc-code and
      bf_inv-doc-attr.attr-code = 'invMultDevice' no-error .
      if available (bf_inv-doc-attr) then invTSD = logical(bf_inv-doc-attr.attr-value) .
      else invTSD = false .
  assign
    varwas-qnty-kg  :visible in browse br-list = ( is-petrol )
    varare-qnty-kg  :visible in browse br-list = ( is-petrol )
    vardiff-qnty-kg :visible in browse br-list = ( is-petrol )
  .
  disable all with frame d-inv-doc.
  display
    fi-val-header
    fi-rub-header
    fi-izlishki-header
    fi-nedostacha-header
    fi-raschet-header
    invTSD
    with frame d-inv-doc .
  hide loc-art in frame d-inv-doc loc-name loc-code in frame d-inv-doc.
  assign
    loc-art = "":U
  .
  assign
  B-chk-doc:POPUP-MENU IN FRAME d-inv-doc = MENU m-chk-doc:HANDLE
  b-chk-doc:menu-mouse = 1.
  assign
  menu-item m-chk-doc-add:sensitive in menu m-chk-doc = (pardoc-mode <> 'ПРОСМОТР':U).
  enable
    b-exit b-history b-arch b-sum-doc b-sum-goods b-help br-list b-lkp a-n-c b-notes b-unscn b-cnt b-marks t-othermoves
    b-chk-doc when is-cdinv = "yes" and t-doc.obj-type = 'маг':U
    with frame d-inv-doc.
  if v-inv-prsr = "yes"
     then enable b-inv-prsrt with frame d-inv-doc.
     else hide b-inv-prsrt in frame d-inv-doc.
  ASSIGN ub.doc-line.fact-qnty :READ-ONLY IN BROWSE br-list = YES.
  enable b-parts with frame d-inv-doc.
  enable b-attr with frame d-inv-doc.
  enable dif-only with frame d-inv-doc.
  if pardoc-mode = 'ПРОСМОТР':U then do:
    if parext-doc-mode = "reason-code" then do:
      enable r-reas t-doc.reason-code with frame d-inv-doc.
    end.
    else do:
      enable b-list when ( t-doc.status_ <> 'накл':U or t-doc.flag_ = yes )
             b-next b-prev
      with frame d-inv-doc.
      if br-handle = ? then hide b-prev b-next in frame d-inv-doc .
    end.
  end.
  else do:
    enable t-doc.wrkr t-doc.agnt t-doc.boss r-wrkr r-agnt r-boss r-reas t-doc.reason-code
           with frame d-inv-doc.
    if t-doc.status_ = 'разрешен':U then do:
      if t-doc.flag_ = no then do:
        enable b-add b-del with frame d-inv-doc.
      end.
      enable b-chg with frame d-inv-doc.
      enable varinvclcwtol varinvclcasol with frame d-inv-doc.
      if t-doc.flag_ then do:
        b-list :label = "&Сканер".
        enable b-clr b-list with frame d-inv-doc.
      end.
      enable b-parts- b-updprt- b-st with frame d-inv-doc.
    end.
    else do:
      enable b-add b-del b-list with frame d-inv-doc.
    end.
  end.
  if t-doc.status_ =  'разрешен':U and
     t-doc.flag_   <> yes          then do:
    display ? @ t-doc.doc-qnty with frame d-inv-doc.
  end.
  else do:
    display t-doc.doc-qnty with frame d-inv-doc.
  end.
  if t-doc.status_ = 'накл':U
  and pardoc-mode <> 'ПРОСМОТР':U then
  enable invTSD with frame d-inv-doc.
    find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
    ub.inv-doc-attr.attr-code = 'invMultDevice' no-error .
    if available (ub.inv-doc-attr) then invTSD = logical(ub.inv-doc-attr.attr-value) .
    find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
    (ub.inv-doc-attr.attr-code = 'ItogInv' or ub.inv-doc-attr.attr-code = 'ItogInvManual') and
    ub.inv-doc-attr.attr-value = string(true) no-error .
    if available (ub.inv-doc-attr) then ItogInv = true .
  display invTSD with frame d-inv-doc.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'clcasol':U ,
                       output p-value ,
                       output p-type )  .
  assign
    varinvclcasol = ( if p-value = "yes" then yes else no )
  .
  display
    varinvclcasol with frame d-inv-doc.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'clcaswt':U ,
                       output p-value ,
                       output p-type )  .
  assign
    varinvclcwtol = ( if p-value = "yes" then yes else no )
  .
  display
    varinvclcwtol with frame d-inv-doc.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'addsum':U ,
                       output p-value ,
                       output p-type )  .
  assign
    varinvclcbef = no
    varinvclcas  = no
    varinvclcex  = no
    varinvclcms  = no
    varinvclcwt  = no
  .
  if lookup( 'bd':U, p-value ) <> 0 then do:
    assign
      varinvclcbef = yes
    .
  end.
  if lookup( 'gen':U, p-value ) <> 0 then do:
    assign
      varinvclcas = yes
    .
  end.
  if lookup( 'ext':U, p-value ) <> 0 then do:
    assign
      varinvclcex = yes
    .
  end.
  if lookup( 'mis':U, p-value ) <> 0 then do:
    assign
      varinvclcms = yes
    .
  end.
  if lookup( 'wst':U, p-value ) <> 0 then do:
    assign
      varinvclcwt = yes
    .
  end.
  if varinvclcex = yes and
     varinvclcms = yes then do:
    find first bf-ext_trn-doc-sum no-lock where
               bf-ext_trn-doc-sum.doc-code = t-doc.doc-code   and
               bf-ext_trn-doc-sum.sum-type = 'ext':U.
    find first bf-mis_trn-doc-sum no-lock where
               bf-mis_trn-doc-sum.doc-code = t-doc.doc-code  and
               bf-mis_trn-doc-sum.sum-type = 'mis':U.
    assign
      vardocextra-qnty = bf-ext_trn-doc-sum.fact-qnty
      vardocextra-base = bf-ext_trn-doc-sum.cost-sum-base
      vardocextra-rubl = bf-ext_trn-doc-sum.cost-sum-rubl
      vardocmiss-qnty  = bf-mis_trn-doc-sum.fact-qnty
      vardocmiss-base  = bf-mis_trn-doc-sum.cost-sum-base
      vardocmiss-rubl  = bf-mis_trn-doc-sum.cost-sum-rubl
    .
    if varr-b = "base" then do:
      assign
        vardocextra-rb = bf-ext_trn-doc-sum.sale-sum-base
        vardocmiss-rb  = bf-mis_trn-doc-sum.sale-sum-base
      .
    end.
    else do:
      assign
        vardocextra-rb = bf-ext_trn-doc-sum.sale-sum-rubl
        vardocmiss-rb  = bf-mis_trn-doc-sum.sale-sum-rubl
      .
    end.
  end.
  else do:
    assign
      vardocextra-qnty = ?
      vardocextra-base = ?
      vardocextra-rubl = ?
      vardocextra-rb   = ?
      vardocmiss-qnty  = ?
      vardocmiss-base  = ?
      vardocmiss-rubl  = ?
      vardocmiss-rb    = ?
    .
  end.
  if varinvclcwt = yes then do:
    find first bf-wt_trn-doc-sum where bf-wt_trn-doc-sum.doc-code = t-doc.doc-code     and
                                       bf-wt_trn-doc-sum.sum-type = 'wst':U no-lock.
    if varr-b = "base" then do:
      assign
        vardocwast-rb      = bf-wt_trn-doc-sum.sale-sum-base
      .
    end.
    else do:
      assign
        vardocwast-rb      = bf-wt_trn-doc-sum.sale-sum-rubl
      .
    end.
  end.
  else do:
    assign
      vardocwast-rb      = ?
    .
  end.
  find bf_trn-reason no-lock where
       bf_trn-reason.reason-code = t-doc.reason-code no-error.
  assign
    rsn-name = ( if available bf_trn-reason then bf_trn-reason.reason-name else "":U )
  .
  if pardoc-mode = 'ДОБАВЛЕНИЕ':U
  then do:
     t-othermoves = yes.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'othermoves':U ,
                       input string(t-othermoves) ) no-error .
  end.
  else do:
     t-othermoves = no .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'othermoves':U ,
                       output p-value ,
                       output p-type )  .
     if p-value > ""
     then
       t-othermoves = logical(p-value)
     .
  end.
  display t-doc.tot-doc t-doc.tot-rubl t-doc.fact-base
          t-doc.fact-rubl t-doc.fact-qnty dif-only varinvclcwtol varinvclcasol
          vardocextra-qnty vardocextra-base vardocextra-rubl vardocextra-rb
          vardocmiss-qnty  vardocmiss-base  vardocmiss-rubl  vardocmiss-rb
          vardocwast-rb
          t-doc.wrkr t-doc.agnt t-doc.boss
          t-doc.re-grading-parts-minus
          t-doc.reason-code rsn-name
          t-doc.doc-date
          t-doc.fact-date
          t-othermoves
  with frame d-inv-doc.
  define variable v-ref-rec67   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-inv-doc t-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display t-doc.wrkr with frame d-inv-doc.
  find cli-buf no-lock where cli-buf.obj-code = input frame d-inv-doc t-doc.wrkr
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-inv-doc.
  end.
  else display ? @ t-doc.wrkr ? @ wrkr-name with frame d-inv-doc.
  define variable v-ref-rec68   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-inv-doc t-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display t-doc.agnt with frame d-inv-doc.
  find cli-buf no-lock where cli-buf.obj-code = input frame d-inv-doc t-doc.agnt
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.agnt cli-buf.obj-name @ agnt-name with frame d-inv-doc.
  end.
  else display ? @ t-doc.agnt ? @ agnt-name with frame d-inv-doc.
  define variable v-ref-rec69   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-inv-doc t-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display t-doc.boss with frame d-inv-doc.
  find cli-buf no-lock where cli-buf.obj-code = input frame d-inv-doc t-doc.boss
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.boss cli-buf.obj-name @ boss-name with frame d-inv-doc.
  end.
  else display ? @ t-doc.boss ? @ boss-name with frame d-inv-doc.
define variable vss-include-info70 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_inventory_add-back-date':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output varadd-back-date
    )  .
end.
if t-doc.status_ = 'запрос':U then do:
   hide t-doc.fact-date
        t-doc.shift-date
        t-doc.shift-num
        t-doc.fact-qnty
        t-doc.shift-name
        r-sht
        in frame d-inv-doc.
end.
else do:
 if (t-doc.status_ = 'накл':U and not t-doc.flag_) then do:
   display t-doc.fact-date with frame d-inv-doc.
   if t-doc.status_ = 'накл':U and
      t-doc.flag_   = no     and
      pardoc-mode <> 'ПРОСМОТР':U   and
      varadd-back-date = yes then do:
     enable t-doc.fact-date  t-doc.doc-date with frame d-inv-doc.
   end.
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,input  'shift-on=request'
  ,output varlog
  ) no-error .
   if error-status :error then do:
     message
       vss-workfile vss-revision vss-description skip
       "Ошибка при запуске процедуры objat" skip
       error-status :get-message(1) skip
       return-value skip
       view-as alert-box error .
     return error.
   end.
   if varlog then do:
     display t-doc.shift-date t-doc.shift-num t-doc.shift-name r-sht with frame d-inv-doc.
     if t-doc.status_ = 'накл':U and
        t-doc.flag_   = no      and
        pardoc-mode <> 'ПРОСМОТР':U    and
        varadd-back-date = yes  then do:
     end.
   end.
   else do:
      hide t-doc.shift-date t-doc.shift-num t-doc.shift-name r-sht in frame d-inv-doc.
   end.
 end.
 else do:
   display t-doc.fact-date t-doc.fact-qnty t-doc.shift-date t-doc.shift-num t-doc.shift-name r-sht with frame d-inv-doc.
 end.
 if t-doc.status_ = 'разрешен':U
 then do:
  hide b-alcmark in frame d-inv-doc.
 end.
end.
  v-is-marking = false.
  assign
    var-qnty-mark  :visible in browse br-list = false
    var-qnty-mark-chk  :visible in browse br-list = false
    var-qnty-mark-tech  :visible in browse br-list = false
  .
  if t-doc.status_ = 'накл':U and not t-doc.flag_ and not pardoc-mode = 'ПРОСМОТР':U
    then do:
      MENU-ITEM m_add-marks:SENSITIVE IN MENU m-marks = TRUE.
        MENU-ITEM m_introduce-marks:SENSITIVE IN MENU m-marks = FALSE.
      MENU-ITEM m_lookup:SENSITIVE IN MENU m-marks = TRUE.
    end.
    else do:
      MENU-ITEM m_add-marks:SENSITIVE IN MENU m-marks = FALSE.
      MENU-ITEM m_introduce-marks:SENSITIVE IN MENU m-marks = FALSE.
      MENU-ITEM m_lookup:SENSITIVE IN MENU m-marks = TRUE.
    end.
  find first ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code no-lock no-error.
  if available (ub.doc-line)
  then do:
    find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
    ub.inv-doc-attr.attr-code = "isManualError" and
    ub.inv-doc-attr.attr-value = string(true) no-error .
    if not available (ub.inv-doc-attr) then do:
    find first ub.goods no-lock where
          ub.goods.artic     = ub.doc-line.artic     and
          ub.goods.prod-type = ub.doc-line.prod-type and
          ub.goods.prod-code = ub.doc-line.prod-code.
    run gds-attr-value (
                          input ub.goods.gds-code,
                          input 'mark-type':U,
                          output v-marking-type,
                          output v-type
                          ).
    if v-marking-type <> "" and v-marking-type <> "not-type" then do:
    if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(ub.doc-line.obj-type, ub.doc-line.obj-code):GetIsMarkingForType(v-marking-type) or v-is-introduce
    then do:
      v-is-marking = true.
      if t-doc.status_ = 'накл':U and not v-is-introduce
        then
          assign
            var-qnty-mark  :visible in browse br-list = true
            var-qnty-mark-chk  :visible in browse br-list = true
            var-qnty-mark-tech :visible in browse br-list = true
          .
      if v-is-introduce
        then
          assign
            var-qnty-mark-chk  :visible in browse br-list = true
          .
    end.
   end.
  end.
  end.
  extent (bcol) = ?.
  hbrowse = browse br-list:handle.
  extent (bcol) = hbrowse:num-columns.
  bcol[1] = hbrowse:first-column.
  do ii = 1 to extent (bcol).
    bcol[ii] = hbrowse:get-browse-column (ii).
  end.
if t-doc.fact-date <> ? and t-doc.fact-date < t-doc.doc-date then hide  b-st b-clr b-parts-  in frame d-inv-doc .
  assign
    frame d-inv-doc :title = t-doc.obj-type + " ":U + string( t-doc.obj-code, ">>>>9":U ) + "  : " + "ИНВЕНТАРИЗАЦИЯ " + t-doc.status_ +
                                                " ":U + string( t-doc.flag_, "+/-":U ) + "     № " + t-doc.doc-code + (if v-is-introduce then ". ПЕРВОНАЧАЛЬНЫЙ ВВОД" else "") +
                                                "                - ":U.
  assign frame d-inv-doc :title = frame d-inv-doc :title +
    ( if parext-doc-mode = "":U          then pardoc-mode       else ( caps( 'редакт-факт':U ) +
    ( if parext-doc-mode = "reason-code" then " кода основания" else "":U ) ) ).
  if parmode <> "no-query":U THEN DO:
    case dif-only:
      when "all" then do:
                open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code by ub.doc-line.line-num.
      end.
      when "shortage" then do:
                open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code and ub.doc-line.fact-qnty < 0, first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code by ub.doc-line.line-num.
      end.
      when "surplus" then do:
                open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code and ub.doc-line.fact-qnty > 0, first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code.
      end.
      when "coincidence" then do:
                open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code and ub.doc-line.fact-qnty = 0, first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code by ub.doc-line.line-num.
      end.
      when "markseqdocqnty" then do:
        def var v-qnty as integer no-undo.
        def var v-rec-list as character no-undo.
        for each ub.doc-line no-lock where ub.doc-line.doc-code = t-doc.doc-code:
          run procmarkqntycheckinv (buffer ub.doc-line, output v-qnty).
          if ub.doc-line.doc-qnty - ub.doc-line.fact-qnty ne v-qnty
            then v-rec-list = string (recid(ub.doc-line)) + "," + v-rec-list.
        end.
                open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code and lookup (string (recid (ub.doc-line)), v-rec-list) > 0, first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code by ub.doc-line.line-num.
      end.
    end case.
    if line-rec <> ? then do:
      reposition br-list to recid line-rec no-error.
    end.
  END.
  find first bf_rvs where bf_rvs.rvs-code = t-doc.out-code no-lock no-error.
  if available (bf_rvs)
  then do:
    def var v-dec as decimal no-undo.
    def var rvsinvsubsDeficitObj as class rvsinvsubs no-undo.
    def var rvsinvsubsOverObj as class rvsinvsubs no-undo.
    def var v-IsRvsInvAlg3 as logical no-undo init false.
    rvsinvsubsDeficitObj = new rvsinvsubs ().
    rvsinvsubsOverObj = new rvsinvsubs ().
    rvsinvsubsOverObj:RvsCode = bf_rvs.rvs-code.
    rvsinvsubsOverObj:ObjType = bf_rvs.obj-type.
    rvsinvsubsOverObj:ObjCode = bf_rvs.obj-code.
    rvsinvsubsDeficitObj:RvsCode = bf_rvs.rvs-code.
    rvsinvsubsDeficitObj:ObjType = bf_rvs.obj-type.
    rvsinvsubsDeficitObj:ObjCode = bf_rvs.obj-code.
    rvsinvsubsDeficitObj:RvsInvStrObj:FillSumByDeficit(rvsinvsubsDeficitObj).
    rvsinvsubsOverObj:RvsInvStrObj:FillSumByOver(rvsinvsubsOverObj).
    if rvsinvsubsDeficitObj:IsRvsInvAlg3 or rvsinvsubsOverObj:IsRvsInvAlg3
    then do:
      v-IsRvsInvAlg3 = true.
    end.
  end.
  if v-IsRvsInvAlg3
  then do with frame d-inv-doc:
    hide
      t-doc.tot-doc
      t-doc.fact-base
      vardocextra-qnty
      vardocextra-base
      vardocextra-rubl
      vardocextra-rb
      vardocmiss-qnty
      vardocmiss-base
      vardocmiss-rubl
      vardocmiss-rb
      fi-izlishki-header
      fi-nedostacha-header
      varinvclcwtol
      varinvclcasol
      fi-raschet-header
      fi-nedostacha-header
      t-doc.doc-qnty
      t-doc.fact-qnty
      t-doc.tot-rubl
      t-doc.fact-rubl
      fi-val-header
      fi-rub-header
      rect-inv-doc
      rect-tog
      rect-trn-doc
    .
    display
      fi-plusbal-header
      fi-minusbal-header
      f-izlheader
      f-notbal
      f-notbal-2
      f-acc
      f-acc-2
      f-meu
      f-meu-2
      f-mnorml
      f-mnorml-2
      f-izlnedos
      f-izlnedos-2
      f-izlheader
      fi-plusbal-header
      fi-minusbal-header
    .
    assign
      f-notbal-2:screen-value = "0"
      f-notbal:screen-value = "0"
      f-izlnedos-2:screen-value = "0"
      f-izlnedos:screen-value = "0"
      f-acc-2:screen-value = "0"
      f-acc:screen-value = "0"
    .
    assign
      f-notbal-2
      f-notbal
      f-izlnedos-2
      f-izlnedos
      f-acc
      f-acc-2
    .
    f-notbal-2 = absolute ( rvsinvsubsDeficitObj:DiffSum ).
    f-acc-2 = rvsinvsubsDeficitObj:MeteringErrWastSum.
    f-mnorml-2 = rvsinvsubsDeficitObj:TPWastSum.
    f-meu-2 = rvsinvsubsDeficitObj:NaturWastageSum.
    f-izlnedos = rvsinvsubsOverObj:DeficitOverSum.
    f-izlnedos-2 = absolut (rvsinvsubsDeficitObj:DeficitOverSum).
    f-notbal = rvsinvsubsOverObj:DiffSum.
    f-acc = rvsinvsubsOverObj:MeteringErrWastSum.
    assign
      f-acc-2:screen-value = string (f-acc-2)
      f-notbal-2:screen-value = string (f-notbal-2)
      f-meu-2:screen-value = string (f-meu-2)
      f-acc:screen-value = string (f-acc)
      f-notbal:screen-value = string (f-notbal)
      f-mnorml-2:screen-value = string (f-mnorml-2)
    .
    assign
      f-izlnedos-2:screen-value = string (f-izlnedos-2)
      f-izlnedos:screen-value = string (f-izlnedos)
    .
  end.
  else do with frame d-inv-doc:
    hide
      f-notbal
      f-notbal-2
      f-acc
      f-acc-2
      f-meu
      f-meu-2
      f-mnorml
      f-mnorml-2
      f-izlnedos
      f-izlnedos-2
      f-izlheader
      fi-plusbal-header
      fi-minusbal-header
    .
  end.
  apply "entry":U to br-list.
end procedure.
procedure ui-on-browse :
define input parameter parmode as character no-undo .
define variable p-value as character no-undo.
define variable p-type  as character no-undo.
    disable br-list with frame d-inv-doc.
    enable br-list with frame d-inv-doc.
    extent (bcol) = ?.
    hbrowse = browse br-list:handle.
    extent (bcol) = hbrowse:num-columns.
    bcol[1] = hbrowse:first-column.
    do ii = 1 to extent (bcol).
        bcol[ii] = hbrowse:get-browse-column (ii).
    end.
  if parmode <> "no-query":U THEN DO:
    case dif-only:
      when "all" then do:
                open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code , first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code by ub.doc-line.line-num.
      end.
      when "shortage" then do:
                open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code and ub.doc-line.fact-qnty < 0, first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code by ub.doc-line.line-num.
      end.
      when "surplus" then do:
                open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code and ub.doc-line.fact-qnty > 0, first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code.
      end.
      when "coincidence" then do:
                open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code and ub.doc-line.fact-qnty = 0, first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code by ub.doc-line.line-num.
      end.
      when "markseqdocqnty" then do:
        def var v-qnty as integer no-undo.
        def var v-rec-list as character no-undo.
        for each ub.doc-line no-lock where ub.doc-line.doc-code = t-doc.doc-code:
          run procmarkqntycheckinv (buffer ub.doc-line, output v-qnty).
          if ub.doc-line.doc-qnty - ub.doc-line.fact-qnty ne v-qnty
            then v-rec-list = string (recid(ub.doc-line)) + "," + v-rec-list.
        end.
                open query br-list for each  ub.doc-line no-lock where       ub.doc-line.doc-code = t-doc.doc-code and lookup (string (recid (ub.doc-line)), v-rec-list) > 0, first ub.goods no-lock where       ub.goods.artic     = ub.doc-line.artic     and       ub.goods.prod-type = ub.doc-line.prod-type and       ub.goods.prod-code = ub.doc-line.prod-code by ub.doc-line.line-num.
      end.
    end case.
    if line-rec <> ? then do:
      reposition br-list to recid line-rec no-error.
    end.
  END.
  apply "entry":U to br-list.
end procedure.
PROCEDURE init-attr-general :
do on error undo, return error return-value :
run cr-tt-upd .
define variable varexist                  as logical   no-undo.
  run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'trdcattr-prikaz-number':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'trdcattr-prikaz-date':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'trdcattr-inv-date':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'trdcattr-fio-agent':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'trdcattr-pos-agent':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'trdcattr-fio-player1':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'trdcattr-pos-player1':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'trdcattr-fio-player2':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'trdcattr-pos-player2':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'trdcattr-fio-player3':U                                                         ,  input  ""                                                         , output varexist ) no-error.
run create-record in this-procedure (  input t-doc.doc-code                                                         ,  input 'trdcattr-pos-player3':U                                                         ,  input  ""                                                         , output varexist ) no-error.
end.
END PROCEDURE.
PROCEDURE cr-tt-upd :
do on error undo, return error return-value :
for each tt-upd-attr: delete tt-upd-attr. end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'trdcattr-prikaz-number':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов инвентаризации." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'trdcattr-prikaz-date':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов инвентаризации." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'trdcattr-inv-date':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов инвентаризации." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'trdcattr-fio-agent':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов инвентаризации." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'trdcattr-pos-agent':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов инвентаризации." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'trdcattr-fio-player1':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов инвентаризации." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'trdcattr-pos-player1':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов инвентаризации." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'trdcattr-fio-player2':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов инвентаризации." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'trdcattr-pos-player2':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов инвентаризации." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'trdcattr-fio-player3':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов инвентаризации." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'trdcattr-pos-player3':U  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-cod in g#trdcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output v-other  ,
                       output tt-upd-attr.proc-attr ,
                       output tt-upd-attr.full-screen-val ,
                       output tt-upd-attr.sort_
                       ) no-error .
                      if error-status :error then do:       message "Ошибка при установке атрибутов инвентаризации." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.  end.
end.
end procedure.
procedure loc-cr-gds-dtl :
  define variable n-c like ub.gds-prt.node-code          no-undo.
  find first ub.gds-dtl where
             ub.gds-dtl.doc-code  = ub.doc-line.doc-code  and
             ub.gds-dtl.artic     = ub.doc-line.artic     and
             ub.gds-dtl.prod-code = ub.doc-line.prod-code and
             ub.gds-dtl.prod-type = ub.doc-line.prod-type no-error.
  if not available ub.gds-dtl then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run termnode in g#library
  (input  ub.goods.prt-root
  ,output n-c
  )  .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crgdsdtl in g#lib-trn
  ( input ub.doc-line.obj-code
   ,input ub.doc-line.obj-type
   ,input t-doc.doc-code
   ,input ub.doc-line.artic
   ,input ub.doc-line.prod-code
   ,input ub.doc-line.prod-type
   ,input n-c
   ,input yes
  )  .
    find first ub.gds-dtl where
               ub.gds-dtl.doc-code  = ub.doc-line.doc-code  and
               ub.gds-dtl.artic     = ub.doc-line.artic     and
               ub.gds-dtl.prod-code = ub.doc-line.prod-code and
               ub.gds-dtl.prod-type = ub.doc-line.prod-type and
               ub.gds-dtl.prt-code  = n-c.
    assign
      ub.gds-dtl.fact-qnty = ub.doc-line.doc-qnty
      ub.gds-dtl.doc-qnty  = 0
    .
  end.
end procedure.
procedure set-cource :
  define variable v-today as date no-undo.
  define variable varbase-code as integer no-undo.
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-today
  )  .
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  t-doc.host-code
  ,output varbase-code
  )  .
  find last ub.curr-accnt no-lock where
            ub.curr-accnt.curr-code  = varbase-code and
            ub.curr-accnt.exch-date <= v-today      use-index pi no-error.
  if not available ub.curr-accnt then do:
    message "На дату" v-today "неизвестен курс базовой валюты." SKIP
            "Сумма по документу в валюте будет рассчитана при закрытии на факт"
    view-as alert-box.
  end.
  else do:
    assign
      t-doc.base-rate  = ub.curr-accnt.exch-rate
      t-doc.base-scale = ub.curr-accnt.exch-scale
    .
  end.
end procedure.
procedure local-add :
  define variable varartic   like ub.doc-line.artic no-undo initial " ":U.
  define variable varmessage as   character         no-undo.
  define variable varnotes   as   character         no-undo.
  define variable vismsg     as logical   no-undo init true.
  define buffer bf_doc-line for ub.doc-line.
  define buffer buf_marking-lines for ub.marking-lines.
  do
  on error undo, return error return-value
  :
    run str/chsgdsls.w (
          input parParentProc ,
          input "inv" ,
          input "Строка инвентаризации № " + t-doc.doc-code + " " + t-doc.status_  ,
          input ? ,
          input ? ,
          input t-doc.host-code,
          input-output varartic,
          output ref-list,
          output table tt-gds-list,
          input false )
          no-error.
    assign
      vartime = time
      lns-cnt = 0
    .
    def var v-is-petrol as logical no-undo.
    def var v-is-pieces as logical no-undo.
    tr:
    for each tt-gds-list
      break by tt-gds-list.nn
    on error undo tr, next tr
    :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input tt-gds-list.artic
  ,  input tt-gds-list.prod-type
  ,  input tt-gds-list.prod-code
  , output v-is-petrol
  , output v-is-pieces
  ) no-error.
      if can-find (first bf_doc-line no-lock where
                   bf_doc-line.doc-code  = t-doc.doc-code)
      then do:
        if not (is-petrol = v-is-petrol)
        then do:
          run waitfram-hide in this-procedure.
          if is-petrol
          then do:
            message
              vss-workfile vss-revision vss-description skip
              substitute("Ошибка при добавлении строки инвентаризации.") skip
              substitute("Запрещено добавлять не топливный товар вместе с топливными.") skip
              return-value skip
              view-as alert-box error .
            undo tr, next tr.
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              substitute("Ошибка при добавлении строки инвентаризации.") skip
              substitute("Запрещено добавлять топливный товар вместе с не топливными.") skip
              return-value skip
              view-as alert-box error .
            undo tr, next tr.
          end.
        end.
      end.
      else is-petrol = v-is-petrol.
      find ub.goods no-lock
        where  ub.goods.gds-code = tt-gds-list.gds-code .
      assign
        lns-cnt = lns-cnt + 1
      .
      run gds-attr-value (
                            input ub.goods.gds-code,
                            input 'mark-type':U,
                            output v-marking-type,
                            output v-type
                            ).
      if not v-marking-type = "tabak" and v-is-introduce
      then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute("Ошибка при добавлении строки инвентаризации. Запрещено добавлять товары, неподлежащие обязательной маркировки. Включен флаг первоначального ввода.") skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo tr, next tr.
      end.
      if v-is-introduce then do:
        def var introdUtd as class introduce no-undo.
        def var jj as integer no-undo.
        find first ub.utd no-lock where ub.utd.doc-code = t-doc.doc-code no-error.
        if not available (ub.utd)
        then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute("Ошибка при добавлении строки в инвентаризацию первоначального ввода. Привязанный документ первоначального ввода не найден.")
            view-as alert-box error .
          undo tr, next tr.
        end.
        introdUtd = new introduce() no-error.
        introdUtd:AddLineUTD(input ub.goods.gds-code, input ub.utd.doc-id, input ub.utd.db-num, output jj).
        if error-status:error
        then do:
          delete object introdUtd no-error.
          message
            vss-workfile vss-revision vss-description skip
            substitute("Ошибка при добавлении строки первоначального ввода.") skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo tr, next tr.
        end.
        delete object introdUtd no-error.
      end.
      if v-marking-type = "tabak" and vismsg and can-find (first buf_marking-lines no-lock
                                                  where buf_marking-lines.gds-code = ub.goods.gds-code and buf_marking-lines.out-code = 'free-zone':U and buf_marking-lines.mark begins 'tech_':U)
      then do:
        vismsg = false.
        message
          substitute("Есть товары с техническими марками") skip
          view-as alert-box warning title "Информация".
      end.
      if can-find (first ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code)
      then do:
        if not v-is-introduce and v-marking-type <> "" and v-marking-type <> "not-type" and
        ((not ObjSrv:Env:ParametrsOfSection:GetSectionEDO(t-doc.obj-type, t-doc.obj-code):GetIsMarkingForType(v-marking-type) and (v-is-marking = true))
        or (ObjSrv:Env:ParametrsOfSection:GetSectionEDO(t-doc.obj-type, t-doc.obj-code):GetIsMarkingForType(v-marking-type) and v-is-marking = false))
        then do:
          message
            substitute("Ошибка при добавлении строки инвентаризации. Совместное добавление товаров, подлежащих маркировке и не подлежащих маркировке, запрещено.") skip
            view-as alert-box error .
          undo tr, next tr.
        end.
      end.
      else do:
        if v-marking-type <> "" and v-marking-type <> "not-type" then do:
        if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(t-doc.obj-type, t-doc.obj-code):GetIsMarkingForType(v-marking-type)
          then v-is-marking = true.
        end.
      end.
      find first bf_doc-line where
                 bf_doc-line.doc-code  = t-doc.doc-code         and
                 bf_doc-line.artic     = ub.goods.artic     and
                 bf_doc-line.prod-type = ub.goods.prod-type and
                 bf_doc-line.prod-code = ub.goods.prod-code no-error.
      if available bf_doc-line then do:
        undo tr, next tr.
      end.
      run waitfram-join in this-procedure (  input "Добавление товаров в документ инвентаризации.",
                                             input substitute( " Добавлено &1.", lns-cnt - 1 ),
                                             input substitute( " Время &1.", string( time - vartime, "hh:mm:ss":U ) ),
                                            output varmessage ).
      run waitfram-show in this-procedure (  input varmessage ).
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_adinvlin in g#lib-trn3
(input  parparentproc
,input  t-doc.doc-code
,input  ub.goods.artic
,input  ub.goods.prod-type
,input  ub.goods.prod-code
,output line-rec
) no-error.
      if error-status :error then do:
        run waitfram-hide in this-procedure.
        message
          vss-workfile vss-revision vss-description skip
          substitute("Ошибка при добавлении строки инвентаризации") skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo tr, next tr.
      end.
      find first ub.doc-line where recid( ub.doc-line ) = line-rec.
      assign
        ub.doc-line.prt-OK = ?
      .
      if t-doc.status_ = 'разрешен':U and
         t-doc.flag_   = no           then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_filinvln in g#lib-trn2
(input  ub.doc-line.doc-code,
 input  ub.doc-line.artic,
 input  ub.doc-line.prod-type,
 input  ub.doc-line.prod-code,
 input  this-procedure:handle
) no-error
.
        if error-status :error then do:
          run waitfram-hide in this-procedure.
          message "Ошибка при заполнении сумм по строке товара: "
                  ub.doc-line.artic " " ub.doc-line.prod-type " " ub.doc-line.prod-code skip
                  return-value skip
          view-as alert-box error.
          undo tr, next tr .
        end.
      end.
    end.
    run waitfram-hide in this-procedure.
    run UI-on         in this-procedure ( input "":U ).
  end.
end procedure.
procedure m-clr-1 :
  if not available ub.doc-line then do:
    message "Неправильно выбрана строка."
    view-as alert-box error buttons ok.
    return error.
  end.
  else do:
    assign
      line-rec = recid( ub.doc-line )
    .
  end.
  find ub.doc-line where recid( ub.doc-line ) = line-rec.
  apply "row-leave":U to browse br-list.
  do transaction on error undo, return error return-value :
    run local-reclcinv in this-procedure ( input "old":U ).
    message "Списать в ноль строку " ub.doc-line.artic " ?"
                    view-as alert-box question buttons ok-cancel update varlog.
    if varlog <> yes then do:
      return.
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_clr-line in g#lib-trn3
(input parparentproc
,input ub.doc-line.doc-code
,input ub.doc-line.artic
,input ub.doc-line.prod-type
,input ub.doc-line.prod-code
,input 'ноль':u
) .
    if ub.doc-line.doc-qnty <> 0 then do:
      message "Не удается обнулить строку." skip
              "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
         view-as alert-box error .
      undo, return error.
    end.
    run local-reclcinv in this-procedure ( input "update":U ).
  end.
  run ui-on in this-procedure ( input "":U ).
end procedure.
procedure m-clr-2 :
  apply "row-leave":U to browse br-list.
  do transaction on error undo, return error return-value :
    assign
      vartime  = time
      varcount = 0
      varlog    = no
    .
    message "Списать в ноль все строки?"
           view-as alert-box question buttons OK-Cancel update varlog.
    if varlog <> yes then do:
      return.
    end.
    for each ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code on error undo, return error return-value :
      assign
        varcount = varcount + 1
      .
      run waitfram-show in this-procedure ( waitfram-join-function(
                                                                    "Списание в ноль всех строк.",
                                                                    substitute( " Обработано строк: &1.", varcount ),
                                                                    substitute( " Время &1.",
                                                                                string( time - vartime, "hh:mm:ss":U ) )
                                                                  )
                                          ) no-error.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_clr-line in g#lib-trn3
(input parparentproc
,input ub.doc-line.doc-code
,input ub.doc-line.artic
,input ub.doc-line.prod-type
,input ub.doc-line.prod-code
,input 'ноль':u
) no-error.
      if error-status :error then do:
        run waitfram-hide in this-procedure no-error.
        undo, return error return-value.
      end.
    end.
    run full-recalc in this-procedure.
  end.
  run waitfram-hide in this-procedure no-error.
  message "Обработано строк :" varcount
  view-as alert-box.
  run UI-on in this-procedure ( input "":U ).
end procedure.
procedure m-clr-3 :
  APPLY "row-leave":U to BROWSE br-list.
  assign
    varlog    = no
    vartime  = time
    varcount = 0
  .
  do transaction on error undo, return error return-value :
    message "Списать в ноль все строки, которые не изменялись ?"
                  view-as alert-box question buttons OK-Cancel update varlog.
    if varlog <> yes then do:
      return no-apply.
    end.
    run waitfram-show in this-procedure ( input "Списание в ноль всех неизмененных строк. ЖДИТЕ..." ).
    for each ub.doc-line where
             ub.doc-line.doc-code = t-doc.doc-code and
             ub.doc-line.prt-ok   = ?              on error undo, return error return-value :
      assign
        varcount = varcount + 1
      .
      run waitfram-show in this-procedure ( waitfram-join-function (
                                                                     "Списание в ноль всех неизмененных строк.",
                                                                     substitute( " Обработано строк: &1.", varcount ),
                                                                     substitute( " Время &1.",
                                                                                 string( time - vartime, "hh:mm:ss":U ) )
                                                                   )
                                          ) no-error.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_clr-line in g#lib-trn3
(input parparentproc
,input ub.doc-line.doc-code
,input ub.doc-line.artic
,input ub.doc-line.prod-type
,input ub.doc-line.prod-code
,input 'ноль':u
) .
      accumulate ub.doc-line.doc-code ( count ).
    end.
    if can-find( first ub.doc-line where
                       ub.doc-line.doc-code =  t-doc.doc-code and
                       ub.doc-line.prt-ok   =  ?              and
                       ub.doc-line.doc-qnty <> 0 )            then do:
      message "Во время сброса в некоторые товары не удалось обнулить." skip
              view-as alert-box error .
    end.
    run full-recalc in this-procedure.
  end.
  run waitfram-hide in this-procedure no-error.
  message "Обработано строк :" ( accum count ub.doc-line.doc-code )
          view-as alert-box.
  run UI-on in this-procedure ( input "":U ).
end procedure.
procedure m-st-1 :
  apply "row-leave":U to browse br-list.
  if not available ub.doc-line then do:
    message "Неправильно выбрана строка."
    view-as alert-box error buttons ok.
    return error.
  end.
  else do:
    assign
      line-rec = recid( ub.doc-line )
    .
  end.
  find ub.doc-line where recid( ub.doc-line ) = line-rec.
  do transaction on error undo, return error return-value :
    run local-reclcinv in this-procedure ( input "old":U ).
    message "Восстановить строку " ub.doc-line.artic " ?"
                      view-as alert-box question buttons OK-Cancel update varlog.
    if varlog <> yes then do:
      return no-apply.
    end.
    RUN loc-cr-gds-dtl in this-procedure.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_clr-line in g#lib-trn3
(input parparentproc
,input ub.doc-line.doc-code
,input ub.doc-line.artic
,input ub.doc-line.prod-type
,input ub.doc-line.prod-code
,input 'исх':u
) .
    run local-reclcinv in this-procedure ( input "update":U ).
  END.
  run waitfram-hide in this-procedure no-error.
end procedure.
procedure m-parts-1 :
  if available ub.doc-line then
  do transaction on error undo, return error return-value:
    assign
      line-rec = RECID( ub.doc-line )
    .
    find ub.doc-line where recid( ub.doc-line ) = line-rec.
    run local-reclcinv in this-procedure ( input "old":u ).
    run loc-cr-gds-dtl in this-procedure.
    assign
      unrv-qnty = 1
    .
    run trg/rsrv-dtl.p ( input        parparentproc,
                     input        'reserv-create':U,
                     buffer       ub.gds-dtl,
                     input-output unrv-qnty,
                     input-output ub.doc-line.price-base,
                     input-output ub.doc-line.price-rubl,
                     input        -1,
                     input        "" ).
    find first ub.doc-line no-lock where recid( ub.doc-line ) = line-rec no-error.
    if available ub.doc-line then do:
      run local-reclcinv in this-procedure ( input "update":U ).
      display fncgele( buffer ub.doc-line )   @ inv-mark              column-label 'К' format "x(1)":U  if ub.doc-line.prt-OK then '*' else ''   @ prt-mark              column-label 'Ш' format "x(1)":U  ub.doc-line.artic                           column-label 'Артикул'  ub.goods.gds-name                           column-label 'Имя ' format "x(150)":U  fncdiffqntykg( buffer ub.doc-line )  @ vardiff-qnty-kg       column-label 'Разница, кг' format "->>>,>>>,>>9.999":U  markqnty( buffer ub.doc-line )  @ var-qnty-mark         column-label 'Кол-во марок' format ">>>>9":U  markqntycheckinv( buffer ub.doc-line )  @ var-qnty-mark-chk     column-label 'Проверено марок' format ">>>>9":U  markqntytech( buffer ub.doc-line )  @ var-qnty-mark-tech    column-label 'Тех. марки' format ">>>>9":U  fncwasqntykg( buffer ub.doc-line )  @ varwas-qnty-kg        column-label 'Было, кг' format "->>>,>>>,>>9.999":U  fncareqntykg( buffer ub.doc-line )  @ varare-qnty-kg        column-label 'Стало, кг' format "->>>,>>>,>>9.999":U  fncdiffqntykg( buffer ub.doc-line )  @ vardiff-qnty-kg       column-label 'Разница, кг' format "->>>,>>>,>>9.999":U  ub.doc-line.doc-qnty - ub.doc-line.fact-qnty   @ varbefore-qnty        column-label 'Было'  wasQuant(ub.doc-line.doc-qnty, invTSD)   @ vdoc-qnty             column-label 'Стало'  ub.doc-line.fact-qnty                           column-label 'Разница'  ub.doc-line.vat-pc                          column-label 'НДС' format ">9.9%":U  ub.goods.unit-base                           column-label 'Ед. изм.'  fncextra-qnty( buffer ub.doc-line )  @ varextra-qnty         column-label 'Излишки'  fncmiss-qnty( buffer ub.doc-line )  @ varmiss-qnty          column-label 'Недостача'  fncbefore-base( buffer ub.doc-line, buffer ub.goods )  @ varbefore-base        column-label 'Было! учет цены(вал)'  fncbefore-rubl( buffer ub.doc-line, buffer ub.goods )  @ varbefore-rubl        column-label 'Было! учет цены(руб)'  fncafter-base( buffer ub.doc-line, buffer ub.goods )  @ varafter-base         column-label 'Стало! учет цены(вал)'  fncafter-rubl( buffer ub.doc-line, buffer ub.goods )  @ varafter-rubl         column-label 'Стало! учет цены(руб)'  fncextra-base( buffer ub.doc-line, buffer ub.goods )  @ varextra-base         column-label 'Излишки! учет цены(вал)'  fncextra-rubl( buffer ub.doc-line, buffer ub.goods )  @ varextra-rubl         column-label 'Излишки! учет цены(руб)'  fncmiss-base( buffer ub.doc-line, buffer ub.goods )  @ varmiss-base          column-label 'Недостача! учет цены(вал)'  fncmiss-rubl( buffer ub.doc-line, buffer ub.goods )  @ varmiss-rubl          column-label 'Недостача! учет цены(руб)'  fncbefore-rb( buffer ub.doc-line, buffer ub.goods )  @ varbefore-rb          column-label 'Было! прод цены'  fncafter-rb( buffer ub.doc-line, buffer ub.goods )  @ varafter-rb           column-label 'Стало! прод цены'  fncextra-rb( buffer ub.doc-line, buffer ub.goods )  @ varextra-rb           column-label 'Излишки! прод цены'  fncmiss-rb( buffer ub.doc-line, buffer ub.goods )  @ varmiss-rb            column-label 'Недостача! прод цены'  fncmiss-without-wastage( buffer ub.doc-line, buffer ub.goods )  @ varmiss-without-wast  column-label 'Нед. без ест. уб.! прод цены'  fncwastage( buffer ub.doc-line, buffer ub.goods )  @ varwastage            column-label 'Ест. убыль! прод цены'  fncwast-rb( buffer ub.doc-line, buffer ub.goods )  @ varwast-rb            column-label 'Фонд. ест. убыли! прод цены'  fncunus-wast-rb( buffer ub.doc-line, buffer ub.goods )  @ varunus-wast-rb       column-label 'Неизр. ест. убыль! прод цены'  ub.goods.gds-code                          column-label 'Код товара' FORMAT "99999999999":U  ub.doc-line.inv-peresort-qnty                          column-label 'Пересортица' format "->>>,>>>,>>9.999":U  fncnode-name( buffer ub.doc-line, buffer ub.goods )   @ scl-name              column-label 'Шкала' format "x(10)":U with browse br-list.
    end.
    run ui-on in this-procedure ( input "no-query" ).
    message "Была произведена пересортица по отрицательным партиям на кол-во: " unrv-qnty
        view-as alert-box info buttons ok.
    assign
      t-doc.re-grading-parts-minus = yes
    .
    display t-doc.re-grading-parts-minus with frame d-inv-doc.
  end.
end procedure.
procedure m-st-2 :
  APPLY "row-leave":U to BROWSE br-list.
  assign
    varcount = 0
    varlog = no
  .
  do transaction on error undo, return error return-value :
    message "Восстановить исходное состояние для всех строк ?"
                    view-as alert-box question buttons OK-Cancel update varlog.
    if varlog <> yes then do:
      return.
    end.
    run waitfram-show in this-procedure ( input "Восстановление всех строк ЖДИТЕ..." ).
    for each ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code on error undo, return error return-value :
      run loc-cr-gds-dtl in this-procedure no-error.
      if error-status :error then do:
        run waitfram-hide in this-procedure no-error.
        undo, return error return-value.
      end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_clr-line in g#lib-trn3
(input parparentproc
,input ub.doc-line.doc-code
,input ub.doc-line.artic
,input ub.doc-line.prod-type
,input ub.doc-line.prod-code
,input 'исх':u
) .
      assign
       varcount = varcount + 1.
    end.
    run full-recalc in this-procedure.
  end.
  run waitfram-hide in this-procedure no-error.
  message "Обработано строк :" ( varcount )
          view-as alert-box.
end procedure.
procedure m-st-3 :
  APPLY "row-leave":U to BROWSE br-list.
  assign
    varcount = 0
    varlog = no
  .
  do transaction on error undo, return error return-value :
    message "Восстановить исходное состояние для всех сброшенных в ноль строк ?"
                    view-as alert-box question buttons OK-Cancel update varlog.
    if varlog <> yes then do:
      return.
    end.
    run waitfram-show in this-procedure ( input "Восстановление списанных в ноль строк. ЖДИТЕ..." ).
    for each ub.doc-line where
             ub.doc-line.doc-code = t-doc.doc-code and
             ub.doc-line.doc-qnty = 0              on error undo, return error return-value :
      RUN loc-cr-gds-dtl in this-procedure.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_clr-line in g#lib-trn3
(input parparentproc
,input ub.doc-line.doc-code
,input ub.doc-line.artic
,input ub.doc-line.prod-type
,input ub.doc-line.prod-code
,input 'исх':u
) .
      assign
        varcount = varcount + 1.
    end.
    run full-recalc in this-procedure.
  END.
  run waitfram-hide in this-procedure no-error.
  message "Обработано строк :" ( varcount )
          view-as alert-box.
end procedure.
procedure m-parts-2 :
  define variable ind        as integer   no-undo.
  define variable varmessage as character no-undo.
  assign
    varlog = no
  .
  do transaction on error undo, return error return-value :
    message "Произвести пересортицу по всем товарам данной инвентаризации, не имеющих резервы?"
    view-as alert-box question buttons OK-Cancel update varlog.
    if varlog <> yes then do:
      return error.
    end.
    for each gds-list :
      delete gds-list .
    end.
    for each  ub.doc-line where ub.doc-line.doc-code  = t-doc.doc-code,
        first ub.goods where ub.goods.artic     = ub.doc-line.artic     and
                                 ub.goods.prod-type = ub.doc-line.prod-type and
                                 ub.goods.prod-code = ub.doc-line.prod-code no-lock
    on error undo, return error return-value
    :
      assign
        ind = ind + 1
      .
      run waitfram-join in this-procedure (  input "Перетасовка отрицательных партий. Строка " + string( ind ),
                                             input substitute( "Товар &1 &2 &3.",
                                                               ub.doc-line.artic,
                                                               ub.doc-line.prod-type,
                                                               ub.doc-line.prod-code ),
                                             input "",
                                            output varmessage ).
      run waitfram-show in this-procedure
        ( input varmessage
        ) no-error.
      assign
        line-rec = RECID( ub.doc-line )
      .
      run loc-cr-gds-dtl in this-procedure.
      assign
        unrv-qnty = 1
      .
      run trg/rsrv-dtl.p ( input        parparentproc,
                       input        'reserv-create':U,
                       buffer       ub.gds-dtl,
                       input-output unrv-qnty,
                       input-output ub.doc-line.price-base,
                       input-output ub.doc-line.price-rubl,
                       input        -1,
                       input        "" ) NO-ERROR.
      if error-status :error then do:
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find gds-list
  where gds-list.prod-type = goods.prod-type
    and gds-list.prod-code = goods.prod-code
    and gds-list.artic     = goods.artic
  no-error .
if available gds-list then do:
  assign
    gds-list.to-del = no
  .
end.
else do:
  define variable v-last74 as integer no-undo .
  find last gds-list use-index oi no-error.
  if available gds-list then do:
    v-last74 = gds-list.order-num .
  end.
  else do:
    v-last74 = 0 .
  end.
  create gds-list .
  buffer-copy goods to gds-list
  assign
    gds-list.to-del = no
    gds-list.order-num = v-last74 + 1
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (gds-list)
  .
end.
        run waitfram-hide in this-procedure no-error.
        undo, next.
      end.
    end.
    run full-recalc in this-procedure.
    assign
      t-doc.re-grading-parts-minus = yes
    .
    display t-doc.re-grading-parts-minus with frame d-inv-doc.
  end.
  run waitfram-hide in this-procedure no-error.
  run UI-on         in this-procedure ( input "":U ).
  if can-find( first gds-list ) then do:
    assign
      varlog = no
    .
    message "По некоторым товарам не удалось уничтожить отрицательные партии." SKIP
            "Будете просматривать список этих товаров?"
      view-as alert-box buttons yes-no update varlog.
    if varlog = yes then do:
      run str/gds-list.w (input parparentproc, t-doc.host-code, t-doc.obj-type, t-doc.obj-code).
    end.
  end.
end procedure.
procedure local-delete :
  define variable rep-rec as recid no-undo.
  do on error undo, return error return-value :
    if not available ub.doc-line then do:
      message "Неправильно выбрана строка."
              view-as alert-box.
      return error.
    end.
    assign
      line-rec = recid( ub.doc-line )
      varlog    = no
    .
    message "Удалить строку документа" ub.doc-line.artic ub.goods.gds-name "?   Вы уверены ?"
                    view-as alert-box question buttons OK-Cancel update varlog.
    if varlog <> yes then do:
      return no-apply.
    end.
    get next br-list.
    if available ub.doc-line then do:
      assign
        rep-rec = recid( ub.doc-line )
      .
    end.
    else do:
      reposition br-list to recid line-rec no-error.
      get prev br-list.
      if available ub.doc-line then do:
        assign
          rep-rec = recid( ub.doc-line )
        .
      end.
    end.
    reposition br-list to recid line-rec no-error.
    find ub.doc-line where recid( ub.doc-line ) = line-rec.
    do transaction on error undo, return error return-value :
      find first ub.goods where ub.goods.artic     = ub.doc-line.artic     and
                               ub.goods.prod-type = ub.doc-line.prod-type and
                               ub.goods.prod-code = ub.doc-line.prod-code no-lock.
      for each ub.marking-attr exclusive-lock where (ub.marking-attr.attr-code = "inv-doc" or ub.marking-attr.attr-code = "inv-doc-scan")
        and can-find (first ub.marking where ub.marking.mark = ub.marking-attr.mark and ub.marking.gds-code = ub.goods.gds-code):
        delete ub.marking-attr.
      end.
      for each ub.utd no-lock where ub.utd.doc-code = ub.doc-line.doc-code:
        for each ub.utd-lines exclusive-lock where ub.utd-lines.db-num = ub.utd.db-num
          and ub.utd-lines.doc-id =  ub.utd.doc-id and ub.utd-lines.gds-code = ub.goods.gds-code:
          for each ub.utd-lines-attr exclusive-lock where ub.utd-lines-attr.db-num = ub.utd-lines.db-num
            and ub.utd-lines-attr.doc-id = ub.utd-lines.doc-id
            and ub.utd-lines-attr.LineNum = ub.utd-lines.LineNum:
            delete ub.utd-lines-attr.
          end.
          for each ub.utd-marking-lines exclusive-lock where ub.utd-marking-lines.db-num = ub.utd-lines.db-num
            and ub.utd-marking-lines.doc-id = ub.utd-lines.doc-id
            and ub.utd-marking-lines.LineNum = ub.utd-lines.LineNum:
            delete ub.utd-marking-lines.
          end.
          delete ub.utd-lines.
        end.
      end.
      run local-reclcinv in this-procedure ( input "old":U    ).
      run local-reclcinv in this-procedure ( input "delete":U ).
      run str/dellninv.p ( buffer ub.doc-line ).
    end.
    assign
      line-rec = ?
    .
    reposition br-list to recid rep-rec no-error.
    run UI-on in this-procedure ( input "":U ).
  end.
end procedure.
procedure local-chg :
  do on error undo, return error return-value :
    if not available ub.doc-line then do:
      message "Неправильный выбор строки."
              view-as alert-box.
      return error.
    end.
    if v-is-marking and not v-is-introduce
    then do:
      message "Запрещено менять кол-во вручную для продукции подлежащей обязательной маркировке."
              view-as alert-box.
      return.
    end.
    assign
      line-rec = recid( ub.doc-line )
    .
    find first ub.units   no-lock where ub.units.unit-name    = ub.goods.unit-base.
    find       ub.gds-prt no-lock where ub.gds-prt.upper-code = ub.goods.prt-root.
    assign
      prt-rec = recid( ub.gds-prt   )
    .
    run local-reclcinv in this-procedure ( input "old":U ).
    ASSIGN line-mode = ( IF t-doc.status_ = 'разрешен':U AND pardoc-mode = 'ИЗМЕНЕНИЕ':U THEN 'ИЗМЕНЕНИЕ':U ELSE 'ПРОСМОТР':U ).
    do transaction on error undo, return error return-value :
      if lookup( '2ед':U, ub.units.type ) > 0 then do:
         run str/parts-l.w
           (  input parparentproc
           ,  input t-doc.obj-type
           ,  input t-doc.obj-code
           ,  input ub.goods.gds-code
           ,  input ub.doc-line.doc-code
           ,  input line-mode
           ,  input 'документ':U
           ,  input 'текущий':U
           ,  input 'документ':U
           , output prt-rec
           ) .
      end.
      else do:
        if v-cntxp-doc-prt <> yes or ub.gds-prt.node-name = '_Пустая шкала':U then do:
          run str/inv-prt.w (
          input parparentproc,
          input pardoc-rec,
          input line-rec,
          input recid(ub.goods),
          input 'БЕЗ_ПРИЗНАКОВ':U,
          input recid (ub.gds-prt),
          input 'корн':U ).
          run ui-on in this-procedure ( input "no-query" ).
        end.
        else do:
          run str/inv-p.p
          ( parparentproc
           , recid(t-doc)
           ,line-rec
           ,recid(ub.goods)
           ,'ШКАЛА':U    ).
        end.
      end.
      find first ub.doc-line where recid( ub.doc-line ) = line-rec.
      run local-reclcinv in this-procedure ( input "update":U ).
    end.
    find first ub.doc-line no-lock where recid( ub.doc-line ) = line-rec no-error.
    if available ub.doc-line then do:
      display fncgele( buffer ub.doc-line )   @ inv-mark              column-label 'К' format "x(1)":U  if ub.doc-line.prt-OK then '*' else ''   @ prt-mark              column-label 'Ш' format "x(1)":U  ub.doc-line.artic                           column-label 'Артикул'  ub.goods.gds-name                           column-label 'Имя ' format "x(150)":U  fncdiffqntykg( buffer ub.doc-line )  @ vardiff-qnty-kg       column-label 'Разница, кг' format "->>>,>>>,>>9.999":U  markqnty( buffer ub.doc-line )  @ var-qnty-mark         column-label 'Кол-во марок' format ">>>>9":U  markqntycheckinv( buffer ub.doc-line )  @ var-qnty-mark-chk     column-label 'Проверено марок' format ">>>>9":U  markqntytech( buffer ub.doc-line )  @ var-qnty-mark-tech    column-label 'Тех. марки' format ">>>>9":U  fncwasqntykg( buffer ub.doc-line )  @ varwas-qnty-kg        column-label 'Было, кг' format "->>>,>>>,>>9.999":U  fncareqntykg( buffer ub.doc-line )  @ varare-qnty-kg        column-label 'Стало, кг' format "->>>,>>>,>>9.999":U  fncdiffqntykg( buffer ub.doc-line )  @ vardiff-qnty-kg       column-label 'Разница, кг' format "->>>,>>>,>>9.999":U  ub.doc-line.doc-qnty - ub.doc-line.fact-qnty   @ varbefore-qnty        column-label 'Было'  wasQuant(ub.doc-line.doc-qnty, invTSD)   @ vdoc-qnty             column-label 'Стало'  ub.doc-line.fact-qnty                           column-label 'Разница'  ub.doc-line.vat-pc                          column-label 'НДС' format ">9.9%":U  ub.goods.unit-base                           column-label 'Ед. изм.'  fncextra-qnty( buffer ub.doc-line )  @ varextra-qnty         column-label 'Излишки'  fncmiss-qnty( buffer ub.doc-line )  @ varmiss-qnty          column-label 'Недостача'  fncbefore-base( buffer ub.doc-line, buffer ub.goods )  @ varbefore-base        column-label 'Было! учет цены(вал)'  fncbefore-rubl( buffer ub.doc-line, buffer ub.goods )  @ varbefore-rubl        column-label 'Было! учет цены(руб)'  fncafter-base( buffer ub.doc-line, buffer ub.goods )  @ varafter-base         column-label 'Стало! учет цены(вал)'  fncafter-rubl( buffer ub.doc-line, buffer ub.goods )  @ varafter-rubl         column-label 'Стало! учет цены(руб)'  fncextra-base( buffer ub.doc-line, buffer ub.goods )  @ varextra-base         column-label 'Излишки! учет цены(вал)'  fncextra-rubl( buffer ub.doc-line, buffer ub.goods )  @ varextra-rubl         column-label 'Излишки! учет цены(руб)'  fncmiss-base( buffer ub.doc-line, buffer ub.goods )  @ varmiss-base          column-label 'Недостача! учет цены(вал)'  fncmiss-rubl( buffer ub.doc-line, buffer ub.goods )  @ varmiss-rubl          column-label 'Недостача! учет цены(руб)'  fncbefore-rb( buffer ub.doc-line, buffer ub.goods )  @ varbefore-rb          column-label 'Было! прод цены'  fncafter-rb( buffer ub.doc-line, buffer ub.goods )  @ varafter-rb           column-label 'Стало! прод цены'  fncextra-rb( buffer ub.doc-line, buffer ub.goods )  @ varextra-rb           column-label 'Излишки! прод цены'  fncmiss-rb( buffer ub.doc-line, buffer ub.goods )  @ varmiss-rb            column-label 'Недостача! прод цены'  fncmiss-without-wastage( buffer ub.doc-line, buffer ub.goods )  @ varmiss-without-wast  column-label 'Нед. без ест. уб.! прод цены'  fncwastage( buffer ub.doc-line, buffer ub.goods )  @ varwastage            column-label 'Ест. убыль! прод цены'  fncwast-rb( buffer ub.doc-line, buffer ub.goods )  @ varwast-rb            column-label 'Фонд. ест. убыли! прод цены'  fncunus-wast-rb( buffer ub.doc-line, buffer ub.goods )  @ varunus-wast-rb       column-label 'Неизр. ест. убыль! прод цены'  ub.goods.gds-code                          column-label 'Код товара' FORMAT "99999999999":U  ub.doc-line.inv-peresort-qnty                          column-label 'Пересортица' format "->>>,>>>,>>9.999":U  fncnode-name( buffer ub.doc-line, buffer ub.goods )   @ scl-name              column-label 'Шкала' format "x(10)":U with browse br-list.
    end.
    run ui-on in this-procedure ( input "no-query" ).
  end.
end procedure.
procedure local-parts :
  if not available ub.doc-line then do:
    message "Неправильный выбор строки - партии недоступны."
            view-as alert-box.
    return error.
  end.
  assign
    line-rec = recid( ub.doc-line )
  .
  do transaction on error undo, return error return-value :
    if pardoc-mode <> 'ПРОСМОТР':U then do:
      run local-reclcinv in this-procedure ( input "old":U ).
    end.
    ASSIGN line-mode = ( IF t-doc.status_ = 'разрешен':U AND pardoc-mode = 'ИЗМЕНЕНИЕ':U THEN 'ИЗМЕНЕНИЕ':U ELSE 'ПРОСМОТР':U ).
    if pardoc-mode = 'ИЗМЕНЕНИЕ':U then do:
      find t-doc        exclusive-lock where recid( t-doc) = pardoc-rec.
      find ub.doc-line  exclusive-lock where recid( ub.doc-line) = line-rec.
    end.
    run str/parts-l.w
      ( input parparentproc
      , input t-doc.obj-type
      , input t-doc.obj-code
      , input ub.goods.gds-code
      , input ub.doc-line.doc-code
      , input line-mode
      , input 'документ':U
      , input 'текущий':U
      , input 'документ':U
      , output prt-rec
      ) .
    if pardoc-mode <> 'ПРОСМОТР':U then do:
      run local-reclcinv in this-procedure ( input "update":U ).
    end.
  end.
  find first ub.doc-line no-lock where recid( ub.doc-line ) = line-rec no-error.
  if available ub.doc-line then do:
    display fncgele( buffer ub.doc-line )   @ inv-mark              column-label 'К' format "x(1)":U  if ub.doc-line.prt-OK then '*' else ''   @ prt-mark              column-label 'Ш' format "x(1)":U  ub.doc-line.artic                           column-label 'Артикул'  ub.goods.gds-name                           column-label 'Имя ' format "x(150)":U  fncdiffqntykg( buffer ub.doc-line )  @ vardiff-qnty-kg       column-label 'Разница, кг' format "->>>,>>>,>>9.999":U  markqnty( buffer ub.doc-line )  @ var-qnty-mark         column-label 'Кол-во марок' format ">>>>9":U  markqntycheckinv( buffer ub.doc-line )  @ var-qnty-mark-chk     column-label 'Проверено марок' format ">>>>9":U  markqntytech( buffer ub.doc-line )  @ var-qnty-mark-tech    column-label 'Тех. марки' format ">>>>9":U  fncwasqntykg( buffer ub.doc-line )  @ varwas-qnty-kg        column-label 'Было, кг' format "->>>,>>>,>>9.999":U  fncareqntykg( buffer ub.doc-line )  @ varare-qnty-kg        column-label 'Стало, кг' format "->>>,>>>,>>9.999":U  fncdiffqntykg( buffer ub.doc-line )  @ vardiff-qnty-kg       column-label 'Разница, кг' format "->>>,>>>,>>9.999":U  ub.doc-line.doc-qnty - ub.doc-line.fact-qnty   @ varbefore-qnty        column-label 'Было'  wasQuant(ub.doc-line.doc-qnty, invTSD)   @ vdoc-qnty             column-label 'Стало'  ub.doc-line.fact-qnty                           column-label 'Разница'  ub.doc-line.vat-pc                          column-label 'НДС' format ">9.9%":U  ub.goods.unit-base                           column-label 'Ед. изм.'  fncextra-qnty( buffer ub.doc-line )  @ varextra-qnty         column-label 'Излишки'  fncmiss-qnty( buffer ub.doc-line )  @ varmiss-qnty          column-label 'Недостача'  fncbefore-base( buffer ub.doc-line, buffer ub.goods )  @ varbefore-base        column-label 'Было! учет цены(вал)'  fncbefore-rubl( buffer ub.doc-line, buffer ub.goods )  @ varbefore-rubl        column-label 'Было! учет цены(руб)'  fncafter-base( buffer ub.doc-line, buffer ub.goods )  @ varafter-base         column-label 'Стало! учет цены(вал)'  fncafter-rubl( buffer ub.doc-line, buffer ub.goods )  @ varafter-rubl         column-label 'Стало! учет цены(руб)'  fncextra-base( buffer ub.doc-line, buffer ub.goods )  @ varextra-base         column-label 'Излишки! учет цены(вал)'  fncextra-rubl( buffer ub.doc-line, buffer ub.goods )  @ varextra-rubl         column-label 'Излишки! учет цены(руб)'  fncmiss-base( buffer ub.doc-line, buffer ub.goods )  @ varmiss-base          column-label 'Недостача! учет цены(вал)'  fncmiss-rubl( buffer ub.doc-line, buffer ub.goods )  @ varmiss-rubl          column-label 'Недостача! учет цены(руб)'  fncbefore-rb( buffer ub.doc-line, buffer ub.goods )  @ varbefore-rb          column-label 'Было! прод цены'  fncafter-rb( buffer ub.doc-line, buffer ub.goods )  @ varafter-rb           column-label 'Стало! прод цены'  fncextra-rb( buffer ub.doc-line, buffer ub.goods )  @ varextra-rb           column-label 'Излишки! прод цены'  fncmiss-rb( buffer ub.doc-line, buffer ub.goods )  @ varmiss-rb            column-label 'Недостача! прод цены'  fncmiss-without-wastage( buffer ub.doc-line, buffer ub.goods )  @ varmiss-without-wast  column-label 'Нед. без ест. уб.! прод цены'  fncwastage( buffer ub.doc-line, buffer ub.goods )  @ varwastage            column-label 'Ест. убыль! прод цены'  fncwast-rb( buffer ub.doc-line, buffer ub.goods )  @ varwast-rb            column-label 'Фонд. ест. убыли! прод цены'  fncunus-wast-rb( buffer ub.doc-line, buffer ub.goods )  @ varunus-wast-rb       column-label 'Неизр. ест. убыль! прод цены'  ub.goods.gds-code                          column-label 'Код товара' FORMAT "99999999999":U  ub.doc-line.inv-peresort-qnty                          column-label 'Пересортица' format "->>>,>>>,>>9.999":U  fncnode-name( buffer ub.doc-line, buffer ub.goods )   @ scl-name              column-label 'Шкала' format "x(10)":U with browse br-list.
  end.
  run ui-on in this-procedure ( input "no-query" ).
end procedure.
procedure local-chk-doc :
define input parameter p-chk-doc-option as character no-undo .
DEFINE VARIABLE varrid-list as character no-undo .
define variable v-bttns as character no-undo .
define variable v-mode as character no-undo .
define variable old-type     as character no-undo.
define variable old-stat     as character no-undo.
define variable old-flag     as logical   no-undo.
define variable old-internal as logical   no-undo.
define variable loc-ref-list as character no-undo.
define buffer t-clients for ub.clients.
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
define variable glog as logical no-undo .
define variable v-line-rec as recid no-undo .
  CASE p-chk-doc-option:
    when "chk-gds" then do:
      run str/invcdlin.w ( input parparentproc
                      ,input (if t-doc.status_ = 'разрешен':U then "b-calc,b-mark":U else '':U)
                      ,input '':U
                      ,input t-doc.doc-code
                      ,input-output varrid-list) no-error.
      if error-status:error then do:
         message
         error-status:get-message(1)  skip
         return-value
         view-as alert-box error .
         .
      end.
      else do:
        if t-doc.status_ = 'разрешен':U then do:
          run UI-on         in this-procedure ( input "":U ).
        end.
      end.
    end.
    when 'ПРОСМОТР':U then do:
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
glog = yes.
FIND FIRST t-clients NO-LOCK WHERE
                    t-clients.obj-code = t-doc.obj-code AND
                    t-clients.obj-type = t-doc.obj-type
    No-ERROR.
IF t-clients.db-num <> v-cntxt-db-num and v-cntxt-db-num <> 0 then do:
    if YES then
    message "Нельзя получить информацию по чекам объекта "  t-doc.obj-code t-doc.obj-type
    "в базе данных N " v-cntxt-db-num
    view-as alert-box.
    glog = no.
end.
else if v-cntxt-db-num = 0 AND t-clients.db-num <> v-cntxt-db-num then do:
    FIND FIRST db No-LOCK WHERE db.db-num = t-clients.db-num No-ERROR.
    if NOT db.send-check then do:
        if YES then
        message "Нельзя получить информацию по чекам объекта "  t-doc.obj-code t-doc.obj-type
        "в базе данных N " v-cntxt-db-num
        view-as alert-box.
        glog = no.
    end.
end.
      if NOT glog then return no-apply.
      assign
      v-bttns = (if t-doc.status_ = 'разрешен':U
                and pardoc-mode = 'ИЗМЕНЕНИЕ':U
                then 'b-sel,b-mark':U
                else (if t-doc.status_ = 'накл':U
                     and t-doc.flag_ <> yes
                     and pardoc-mode = 'ИЗМЕНЕНИЕ':U
                     then 'b-del':U
                     else '':U)
                )
      v-mode =  'vt':U
      varrid-list = '':U
      .
      run str/chk-docs.w (
                     input parparentproc
                    ,input v-bttns
                    ,input v-mode
                    ,input ?
                    ,input t-doc.obj-type
                    ,input t-doc.obj-code
                    ,input t-doc.doc-code
                    ,input '':U
                    ,input 0
                    ,input ?
                    ,input ?
                    ,input 0
                    ,output varrid-list) no-error.
      if t-doc.status_ = 'разрешен':U
      and varrid-list <> "":U then do:
        message
        "Хотите посчитать количества по выделенным чекам инвентаризации?"
        view-as alert-box question buttons yes-no update glog.
        if glog then do:
          run str/inc-invd.w (
                           input parparentproc
                          ,input 'ИЗМЕНЕНИЕ':U
                          ,input varrid-list
                          ,input ?
                          ,input t-doc.obj-type
                          ,input t-doc.obj-code
                          ,buffer t-doc
                          ) no-error .
          if t-doc.status_ = 'разрешен':U and pardoc-mode = 'ИЗМЕНЕНИЕ':U then do:
            run set-cource in this-procedure.
            run gbl/calc-trn.p ( input parparentproc, input recid( t-doc ) ).
            run str/clcsumga.p ( input t-doc.doc-code ).
          end.
          run UI-on         in this-procedure ( input "":U ).
        end.
      end.
    end.
    when 'ДОБАВЛЕНИЕ':U then do:
      run str/inc-invd.w (
                       input parparentproc
                      ,input 'ДОБАВЛЕНИЕ':U
                      ,input varrid-list
                      ,input ?
                      ,input t-doc.obj-type
                      ,input t-doc.obj-code
                      ,buffer t-doc
                      ) no-error .
      if t-doc.status_ = 'разрешен':U and pardoc-mode = 'ИЗМЕНЕНИЕ':U then do:
        run set-cource in this-procedure.
        run gbl/calc-trn.p ( input parparentproc, input recid( t-doc ) ).
        run str/clcsumga.p ( input t-doc.doc-code ).
      end.
      run UI-on         in this-procedure ( input "":U ).
    end.
  END CASE.
end.
end procedure.
procedure local-list :
define variable old-handle   as handle    no-undo.
define variable old-type     as character no-undo.
define variable old-stat     as character no-undo.
define variable old-flag     as logical   no-undo.
define variable old-internal as logical   no-undo.
define variable loc-ref-list as character no-undo.
define variable v-tmp-recid as recid no-undo .
define buffer old-doc for ub.trn-doc.
  do on error undo, return error return-value :
    assign
      old-handle   = br-handle
    .
    if t-doc.status_ =  'накл':U and
       t-doc.flag_   <> yes     then do:
      run str/use-list.p (input parparentproc, input-output line-rec, input recid(t-doc) , input yes , input ? ).
    end.
    else do:
      if t-doc.status_ = 'разрешен':U and pardoc-mode = 'ИЗМЕНЕНИЕ':U then do:
        run str/scan.p ( parparentproc, input no , input recid(t-doc) ,input ? ).
      end.
      else do:
        assign
          varlog = no
        .
        if t-doc.status_ = 'накл':U or t-doc.status_ = 'разрешен':U and t-doc.flag_ <> yes then do:
          assign
            varlog = yes
          .
          if can-find( first old-doc no-lock where old-doc.inv-num = t-doc.doc-code ) then do:
            assign
              varlog = no
            .
            message "Сформировать заново список документов, мешающих включению инвентаризации ?"
                            view-as alert-box question buttons Yes-No update varlog.
          end.
        end.
        if varlog then do:
          run str/inv-lst.p ( input parparentproc
                        , input t-doc.host-code
                        , input t-doc.obj-type
                        , input t-doc.obj-code
                        , input t-doc.doc-code ).
        end.
        v-tmp-recid = recid(t-doc).
        run str/all-docs.w ( input parparentproc,
                             input ?,
                             input ?,
                             input ?,
                             input 'МЕШАЮТ':U,
                             input ?,
                             input ?,
                             input ?,
                             input ?,
                             input "b-sel":U,
                             input ?,
                             input ?,
                             input recid(t-doc) ,
                             output loc-ref-list ).
        find t-doc no-lock where recid( t-doc ) = v-tmp-recid.
        apply "entry":U to b-exit in frame d-inv-doc.
      end.
      assign
        br-handle  = old-handle
      .
      if t-doc.status_ = 'разрешен':U and pardoc-mode = 'ИЗМЕНЕНИЕ':U then do:
        run full-recalc in this-procedure.
      end.
    end.
    run UI-on in this-procedure ( input "":U ).
  end.
end procedure.
procedure minus-string :
  define input-output parameter parstring as character no-undo.
  define input        parameter parvalue  as character no-undo.
  define variable loc-varvalue as character no-undo .
  define variable i        as integer   no-undo.
    do on error undo, return error return-value :
    do i = 1 to num-entries( parstring ) :
      if entry( i, parstring ) <> parvalue then do:
        assign
          loc-varvalue = loc-varvalue + min( loc-varvalue, "," ) + entry( i, parstring )
        .
      end.
    end.
    if parstring = loc-varvalue then do:
      return error substitute( "В строке &1 не найден элемент &2.", parstring, parvalue ).
    end.
    assign
      parstring = loc-varvalue
    .
  end.
end procedure.
procedure local-chg-wtol :
  define variable vartype  as character no-undo.
  do transaction on error undo, return error return-value :
    assign frame d-inv-doc
      varinvclcwtol
    .
    if varinvclcwtol = yes then do:
      message "Вы хотите рассчитать суммы естественной убыли?"
              "В дальнейшем суммы будут пересчитываться при каждом изменении в документе."
      view-as alert-box question buttons yes-no update varlog.
      if varlog = yes then do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_rcallfct in g#lib-rwds ( input              t-doc.doc-code ,
                       input              yes ,
                       input              no ,
                       input              this-procedure :handle ,
                       input-output table tt-wast-line ,
                       input-output table tt-allsum-line ,
                       input-output table tt-doc-line-sum ,
                       input-output table tt-clcparts ,
                       input-output table temp-parts ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'clcaswt':U ,
                       input yes )  .
      end.
    end.
    else do:
      message "Вы хотите не рассчитывать суммы естественной убыли при каждом изменении документа и пересчитать их на факт?"
      view-as alert-box question buttons yes-no update varlog.
      if varlog = yes then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'addsum':U ,
                       output varvalue ,
                       output vartype )  .
        run minus-string in this-procedure ( input-output varvalue, input 'wst':U ).
        if varinvclcspvalue = "yes" then do:
          run minus-string in this-procedure ( input-output varvalue, input 'wstc':U ).
        end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'addsum':U ,
                       input varvalue )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'clcaswt':U ,
                       input no )  .
      end.
    end.
    run ui-on in this-procedure ( input "":U ).
  end.
end procedure.
procedure local-chg-asol :
  define variable vartype     as character no-undo.
  do transaction on error undo, return error return-value :
    assign frame d-inv-doc
      varinvclcasol
    .
    if varinvclcasol = yes then do:
      message "Вы хотите рассчитать суммы по документу?" skip
              "В дальнейшем суммы будут пересчитываться при каждом изменении в документе."
      view-as alert-box question buttons yes-no update varlog.
      if varlog = yes then do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_rcallfct in g#lib-rwds ( input              t-doc.doc-code ,
                       input              no ,
                       input              yes ,
                       input              this-procedure :handle ,
                       input-output table tt-wast-line ,
                       input-output table tt-allsum-line ,
                       input-output table tt-doc-line-sum ,
                       input-output table tt-clcparts ,
                       input-output table temp-parts ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'clcasol':U ,
                       input yes )  .
      end.
    end.
    else do:
      message "Вы хотите не рассчитывать суммы по документу при каждом изменении документа и пересчитать их на факт?"
      view-as alert-box question buttons yes-no update varlog.
      if varlog = yes then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'addsum':U ,
                       output varvalue ,
                       output vartype )  .
        run minus-string in this-procedure ( input-output varvalue, input 'gen':U ) .
        run minus-string in this-procedure ( input-output varvalue, input 'ext':U   ) .
        run minus-string in this-procedure ( input-output varvalue, input 'mis':U    ) .
        run minus-string in this-procedure ( input-output varvalue, input 'ad':U   ) .
        if varinvclcspvalue = "yes" then do:
          run minus-string in this-procedure ( input-output varvalue, input 'genc':U ) .
          run minus-string in this-procedure ( input-output varvalue, input 'extc':U   ) .
          run minus-string in this-procedure ( input-output varvalue, input 'misc':U    ) .
          run minus-string in this-procedure ( input-output varvalue, input 'acd':U   ) .
        end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'addsum':U ,
                       input varvalue )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'clcasol':U ,
                       input no )  .
      end.
    end.
  end.
end procedure.
procedure fnd-goods :
  if available  ub.doc-line then do:
     find first ub.goods no-lock where
                ub.goods.artic     = ub.doc-line.artic     and
                ub.goods.prod-type = ub.doc-line.prod-type and
                ub.goods.prod-code = ub.doc-line.prod-code.
     assign
       gds-rec = recid( ub.goods )
     .
  end.
  else do:
  assign
    gds-rec = ?
  .
  end.
end procedure.
procedure local-reclcinv :
  define input parameter parmode as character no-undo.
  do on error undo, return error return-value :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_reclcinv in g#lib-trn2
(
input        parmode,
input        recid(ub.doc-line),
input        t-doc.doc-code,
input-output vartot-docold,
input-output vartot-rublold,
input-output i-total-doc-line_tot-ovold,
input-output i-total-doc-line_fact-rublold,
input-output i-total-doc-line_fact-baseold,
input-output i-total-doc-line_fact-qntyold,
input-output i-total-doc-line_doc-qntyold,
input-output i-total-doc-line_cli-qntyold,
input-output i-total-parts_fact-baseold,
input-output i-total-parts_fact-rublold,
input-output i-total-parts_fact-qntyold
) .
  end.
end procedure.
procedure local-updprt- :
  if not available ub.doc-line then do:
    message "Неправильный выбор строки - партии недоступны."
            view-as alert-box.
    return error.
  end.
  assign
    line-rec = RECID( ub.doc-line )
  .
  do transaction on error undo, return error return-value :
    run local-reclcinv in this-procedure ( input "old":U ).
    ASSIGN line-mode = ( IF t-doc.status_ = 'разрешен':U AND pardoc-mode = 'ИЗМЕНЕНИЕ':U THEN 'ИЗМЕНЕНИЕ':U ELSE 'ПРОСМОТР':U ).
    if pardoc-mode = 'ИЗМЕНЕНИЕ':U then do:
      find t-doc       exclusive-lock where recid( t-doc       ) = pardoc-rec.
      find ub.doc-line exclusive-lock where recid( ub.doc-line ) = line-rec.
    end.
    define variable v-parts-recid as recid no-undo .
    run str/partsneg.w
      (input  parparentproc
      ,input  ub.doc-line.doc-code
      ,input  'ИЗМЕНЕНИЕ':U
      ,input-output v-parts-recid
      ).
    run local-reclcinv in this-procedure ( input "update":U ) .
  end.
end procedure.
procedure full-recalc:
  run set-cource in this-procedure.
  run gbl/calc-trn.p ( input parparentproc, input recid( t-doc ) ).
  run str/clcsumga.p ( input t-doc.doc-code ).
end procedure.
procedure inv-line_qnty :
  define  input parameter p-doc-line-rec as recid     no-undo.
  define  input parameter p-mode         as character no-undo.
  define output parameter p-qnty-kg      as decimal   no-undo.
  define buffer buf_doc-line for ub.doc-line.
  define buffer buf_inv-line for ub.inv-line.
  do on error undo, return error return-value :
    find first buf_doc-line no-lock where
        recid( buf_doc-line ) = p-doc-line-rec no-error.
    if not available buf_doc-line then do:
      assign
        p-qnty-kg = ?
      .
      return.
    end.
    find first buf_inv-line no-lock where
               buf_inv-line.doc-code  = buf_doc-line.doc-code  and
               buf_inv-line.artic     = buf_doc-line.artic     and
               buf_inv-line.prod-type = buf_doc-line.prod-type and
               buf_inv-line.prod-code = buf_doc-line.prod-code no-error.
    if not available buf_inv-line then do:
      assign
        p-qnty-kg = ?
      .
      return.
    end.
    case p-mode :
      when "was"  then do:
        assign
          p-qnty-kg = buf_inv-line.before-cli-qnty
        .
      end.
      when "are"  then do:
        assign
          p-qnty-kg = buf_inv-line.wast-cli-qnty
        .
      end.
      when "diff" then do:
        assign
          p-qnty-kg = buf_doc-line.cli-qnty
        .
      end.
    end case.
  end.
end procedure.
procedure check-reason :
  define variable j_rsn-code like ub.trn-reason.reason-code no-undo.
  define buffer bf_trn-reason for ub.trn-reason.
  do on error undo, return error return-value :
    assign j_rsn-code = ( input frame d-inv-doc t-doc.reason-code ).
    find first bf_trn-reason no-lock where
               bf_trn-reason.reason-code = j_rsn-code no-error.
    if not available bf_trn-reason then do:
      if j_rsn-code <> ? and j_rsn-code <> 0 then do:
        message "Неверно указано основание (причина) создания документа." view-as alert-box error.
      end.
      assign
        rsn-name = "":U
      .
      display rsn-name with frame d-inv-doc.
      if j_rsn-code = ? or j_rsn-code = 0 then do:
        assign
          t-doc.reason-code = 0
        .
        return.
      end.
      else do:
        undo, return error.
      end.
    end.
    assign
      rsn-name = bf_trn-reason.reason-name
    .
    display rsn-name with frame d-inv-doc.
    assign
      frame d-inv-doc t-doc.reason-code
    .
  end.
end procedure.
procedure select-reason :
  define variable j-rsn-code like ub.trn-reason.reason-code no-undo.
  define buffer bf_trn-reason for ub.trn-reason.
  do on error undo, return error return-value :
    assign
      j-rsn-code = ( input frame d-inv-doc t-doc.reason-code )
    .
    run str/trn-reas.w ( input ParParentProc, input 'выбор':U, input-output j-rsn-code ).
    find first bf_trn-reason no-lock where
               bf_trn-reason.reason-code = j-rsn-code no-error.
    if available bf_trn-reason then do:
      assign
        rsn-name          = bf_trn-reason.reason-name
        t-doc.reason-code = bf_trn-reason.reason-code
      .
      display t-doc.reason-code
              rsn-name
      with frame d-inv-doc.
    end.
  end.
end procedure.
PROCEDURE chk-upd-date :
define input parameter parself-name as character no-undo.
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
if input frame d-inv-doc t-doc.fact-date  <> t-doc.fact-date  or
   input frame d-inv-doc t-doc.shift-date <> t-doc.shift-date or
   input frame d-inv-doc t-doc.shift-num  <> t-doc.shift-num then do:
if parself-name = "fact-date" then do:
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-today
  )  .
  if input frame d-inv-doc t-doc.fact-date > v-today then do:
     message "Дата больше сегодняшней даты на объекте." view-as alert-box error.
     display t-doc.fact-date with frame d-inv-doc.
     return error.
  end.
  if input frame d-inv-doc t-doc.fact-date < v-today - 7 then do:
     varlog = yes.
     message "Заведенная факт дата отличается более чем на 7 дней от сегодняшней даты на объекте."
             "Отказаться от заведения даты?" view-as alert-box question
             buttons yes-no update varlog.
     if varlog then do:
        display t-doc.fact-date with frame d-inv-doc.
        return error.
     end.
  end.
define variable v-value-character as character no-undo .
define variable v-value-date      as date no-undo .
define variable v-value-decimal   as decimal no-undo .
define variable v-value-integer   as integer no-undo .
define variable v-value-logical   as logical no-undo .
define variable v-tth             as handle no-undo .
define variable v-back-date as logical   no-undo .
define variable v-back-date-type as character no-undo .
 if t-doc.fact-date < v-today then do:
      delete object v-tth no-error.
      run adm/shattri.p (
           input "get":U
          ,input v-cntxt-obj-type
          ,input v-cntxt-obj-code
          ,input 'nakl_par':U
          ,input  "back-date"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-back-date
          ,output v-back-date-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
          if error-status :error  then v-back-date = false .
          delete object v-tth no-error.
    if v-back-date <> true then do:
      message "Запрещено работать задним числом !" view-as alert-box information .
      display t-doc.fact-date with frame d-inv-doc.
      return error.
    end.
 end.
  assign varlog = no.
define variable vss-include-info77 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_inventory_add-back-date':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
  if varlog = no then do:
     display t-doc.fact-date with frame d-inv-doc.
     return error.
  end.
  assign varlog = no.
  message "Вы хотите изменить фактическую дату?" skip
          "Если дату задать как '?' она при закрытии на факт проставится днем закрытия."
  view-as alert-box question buttons yes-no update varlog.
  if not varlog then do:
     display t-doc.fact-date with frame d-inv-doc.
     return error.
  end.
end.
assign frame d-inv-doc
  t-doc.fact-date
  t-doc.shift-date
  t-doc.shift-num
  t-doc.shift-name.
  assign
    t-doc.fact-time = (24 * 60 * 60)
    .
end.
END PROCEDURE.
PROCEDURE proc-shift-num :
define buffer bf_shift-obj   for ub.shift-obj.
  if input frame d-inv-doc t-doc.shift-num <> t-doc.shift-num then do:
    if input frame d-inv-doc t-doc.shift-date <> ? then do:
      find first bf_shift-obj where bf_shift-obj.obj-type   = t-doc.obj-type                             and
                                    bf_shift-obj.obj-code   = t-doc.obj-code                             and
                                    bf_shift-obj.shift-date = input frame d-inv-doc t-doc.shift-date and
                                    bf_shift-obj.shift-num  = input frame d-inv-doc t-doc.shift-num  no-lock no-error.
      if not available bf_shift-obj then do:
        message "Не найдена смена: " t-doc.obj-type " " t-doc.obj-code
                " Дата " input frame d-inv-doc t-doc.shift-date " Порядок смены " input frame d-inv-doc t-doc.shift-num " ."
        view-as alert-box error.
        display t-doc.shift-num with frame d-inv-doc.
        run proc-sht no-error.
        if error-status:error then do:
          return error.
        end.
      end.
      else do:
        assign
          t-doc.shift-date = bf_shift-obj.shift-date
          t-doc.shift-num  = bf_shift-obj.shift-num
          t-doc.shift-name = bf_shift-obj.shift-name.
        display t-doc.shift-date t-doc.shift-num t-doc.shift-name with frame d-inv-doc.
        if t-doc.fact-date = ? then do:
          assign
            t-doc.fact-date = t-doc.shift-date
            t-doc.fact-time = (24 * 60 * 60).
          display t-doc.fact-date with frame d-inv-doc.
        end.
      end.
    end.
  end.
end procedure.
procedure proc-shift-name :
  define buffer bf_shift-obj   for ub.shift-obj.
  define variable varfind-shift as integer initial 0.
  define variable varshift-date like ub.shift-obj.shift-date no-undo.
  define variable varshift-num  like ub.shift-obj.shift-num  no-undo.
  if input frame d-inv-doc t-doc.shift-name <> t-doc.shift-name then do:
    if input frame d-inv-doc t-doc.shift-date <> ? then do:
      for each  bf_shift-obj where bf_shift-obj.obj-type   = t-doc.obj-type                             and
                                   bf_shift-obj.obj-code   = t-doc.obj-code                             and
                                   bf_shift-obj.shift-date = input frame d-inv-doc t-doc.shift-date and
                                   bf_shift-obj.shift-name = input frame d-inv-doc t-doc.shift-name no-lock on error undo, return error return-value :
        assign
          varfind-shift = varfind-shift + 1
          varshift-date = bf_shift-obj.shift-date
          varshift-num  = bf_shift-obj.shift-num.
      end.
      if varfind-shift = 0 or varfind-shift > 1 then do:
        if varfind-shift = 0 then do:
          message "Не найдена смена: " t-doc.obj-type " " t-doc.obj-code
                  " Дата " input frame d-inv-doc t-doc.shift-date " Номер смены " input frame d-inv-doc t-doc.shift-name " ."
          view-as alert-box error.
        end.
        else do:
          message "Найдено более одной смены с одним номером в сменном дне. Объект: " t-doc.obj-type " " t-doc.obj-code
                  " Дата " input frame d-inv-doc t-doc.shift-date " Номер смены " input frame d-inv-doc t-doc.shift-name " ."
          view-as alert-box error.
        end.
        display t-doc.shift-name with frame d-inv-doc.
        run proc-sht no-error.
        if error-status:error then do: return error. end.
      end.
      else do:
        assign frame d-inv-doc
          t-doc.shift-name.
        assign
          t-doc.shift-date = varshift-date
          t-doc.shift-num  = varshift-num.
        display t-doc.shift-date t-doc.shift-num t-doc.shift-name with frame d-inv-doc.
        if t-doc.fact-date = ? then do: assign t-doc.fact-date = t-doc.shift-date t-doc.fact-time = (24 * 60 * 60). display t-doc.fact-date with frame d-inv-doc. end.
      end.
    end.
  end.
end procedure.
PROCEDURE proc-sht :
define buffer bf_shift-obj   for ub.shift-obj.
  define variable varrid-list as character no-undo.
  define variable varrecid    as recid     no-undo.
  assign
    varrid-list = "".
  run str/sht-all.w (parparentproc, t-doc.obj-type, t-doc.obj-code, 'b-sel', 'obj', t-doc.obj-type, t-doc.obj-code,'':u, input-output varrid-list) no-error.
  if error-status:error or varrid-list = "":u then do:
    return error.
  end.
  else do:
    assign
      varrecid = integer (entry(1, varrid-list)).
    find first bf_shift-obj where recid(bf_shift-obj) = varrecid no-lock no-error.
    if available bf_shift-obj then do:
      assign
        t-doc.shift-date = bf_shift-obj.shift-date
        t-doc.shift-num  = bf_shift-obj.shift-num
        t-doc.shift-name = bf_shift-obj.shift-name.
      display t-doc.shift-date t-doc.shift-num t-doc.shift-name with frame d-inv-doc.
      if t-doc.fact-date = ? then do:
        assign
          t-doc.fact-date = t-doc.shift-date
          t-doc.fact-time = (24 * 60 * 60).
        display t-doc.fact-date with frame d-inv-doc.
      end.
    end.
  end.
END PROCEDURE.
procedure ver-price :
define buffer buf_gds-dtl for ub.gds-dtl  .
  do
  on error undo, return error return-value
  :
    if pardoc-mode <> 'ИЗМЕНЕНИЕ':U then return .
    if t-doc.status_ <> 'разрешен':U then return .
    run  waitfram-show in this-procedure  ("Проверка цены ...") .
    for each buf_gds-dtl where buf_gds-dtl.doc-code = t-doc.doc-code :
        if buf_gds-dtl.price-rubl = 0 or buf_gds-dtl.price-rubl = ? then do:
define variable vss-include-info78 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_set-pr in g#lib-trn3
  ( input recid(buf_gds-dtl)
  , input no
  , input ?
  ) no-error.
            if buf_gds-dtl.price-rubl = 0 or buf_gds-dtl.price-rubl = ? then do:
               v-long-char = v-long-char + substitute(" Сделайте переоценку по товару : &1;&2;&3 " ,
               buf_gds-dtl.artic, buf_gds-dtl.prod-type, buf_gds-dtl.prod-code )  + chr(10) .
            end.
        end.
    end.
    define buffer buf_doc-line for ub.doc-line  .
    define buffer buf_gds-obj for ub.gds-obj  .
    for each buf_doc-line no-lock where
             buf_doc-line.doc-code = t-doc.doc-code :
        find first buf_gds-obj no-lock where
                   buf_gds-obj.artic = buf_doc-line.artic and
                   buf_gds-obj.prod-type = buf_doc-line.prod-type and
                   buf_gds-obj.prod-code = buf_doc-line.prod-code and
                   buf_gds-obj.obj-type = t-doc.obj-type and
                   buf_gds-obj.obj-code = t-doc.obj-code no-error .
        if not available buf_gds-obj or buf_gds-obj.price-sale = 0 then do:
           find first buf_gds-dtl no-lock where
                   buf_gds-dtl.doc-code = buf_doc-line.doc-code and
                   buf_gds-dtl.artic = buf_doc-line.artic and
                   buf_gds-dtl.prod-type = buf_doc-line.prod-type and
                   buf_gds-dtl.prod-code = buf_doc-line.prod-code no-error .
                 if not available buf_gds-dtl then do:
                    v-long-char = v-long-char + substitute(" Нет переоценки по товару : &1;&2;&3 " ,
                    buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code )  + chr(10) .
                 end.
        end.
    end.
  run waitfram-hide in this-procedure .
  if v-long-char <> "" then do:
  define variable v-ok as logical   no-undo .
  run gbl/d-longchar.w (
        ?,
        'Editor_row=2\':u
      + 'title=Мешает инвентаризации (Если количество не будет = 0 ):\':u
      + 'Editor_col=1\':u
      + 'Editor_width=96\':u
      + 'Editor_height=21\':u
      + 'readonly=yes\':u
    ,input-output v-long-char
    ,output v-ok ) no-error .
    end.
  end.
end procedure.
procedure go-line :
  define input parameter rec as recid no-undo.
  run UI-on in this-procedure ( input "":U ).
  if rec ne ?
    then reposition br-list to recid rec .
end procedure.
