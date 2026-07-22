DEFINE TEMP-TABLE acc-stk-line NO-UNDO LIKE ub.stk-line
       field ext-doc-type-full as character
       field order as integer
       field sum-base-sale like ub.stk-line.sum-base
       field sum-rubl-sale like ub.stk-line.sum-base
       field vat-base-sale like ub.stk-line.sum-base
       field vat-rubl-sale like ub.stk-line.sum-base
       field slt-base-sale like ub.stk-line.sum-base
       field slt-rubl-sale like ub.stk-line.sum-base
       field road-tax-base-sale like ub.stk-line.sum-base
       field road-tax-rubl-sale like ub.stk-line.sum-base
       field excise-base-sale like ub.stk-line.sum-base
       field excise-rubl-sale like ub.stk-line.sum-base
       field transport-base-sale like ub.stk-line.sum-base
       field transport-rubl-sale like ub.stk-line.sum-base
       field other-base-sale like ub.stk-line.sum-base
       field other-rubl-sale like ub.stk-line.sum-base
       field sum-base-doc like ub.stk-line.sum-base
       field sum-rubl-doc like ub.stk-line.sum-base
       field vat-base-doc like ub.stk-line.sum-base
       field vat-rubl-doc like ub.stk-line.sum-base
       field slt-base-doc like ub.stk-line.sum-base
       field slt-rubl-doc like ub.stk-line.sum-base
       field road-tax-base-doc like ub.stk-line.sum-base
       field road-tax-rubl-doc like ub.stk-line.sum-base
       field excise-base-doc like ub.stk-line.sum-base
       field excise-rubl-doc like ub.stk-line.sum-base
       field transport-base-doc like ub.stk-line.sum-base
       field transport-rubl-doc like ub.stk-line.sum-base
       field other-base-doc like ub.stk-line.sum-base
       field other-rubl-doc like ub.stk-line.sum-base
       index pi order
       .
DEFINE NEW GLOBAL SHARED TEMP-TABLE tt-clients NO-UNDO LIKE ub.clients.
DEFINE NEW GLOBAL SHARED TEMP-TABLE tt-goods NO-UNDO LIKE ub.goods.
DEFINE TEMP-TABLE tt-ot-line NO-UNDO LIKE ub.ot-line.
CREATE WIDGET-POOL.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр складского архива по товару".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
define variable varis-calend     as integer   no-undo.
define variable varis-shift-num  as logical   no-undo.
define variable vardate-start    as date      no-undo.
define variable vardate-end      as date      no-undo.
define variable varshift-start   as integer   no-undo.
define variable varshift-end     as integer   no-undo.
define variable varext-doc-type  as character no-undo.
define variable varrubl-base     as integer   no-undo.
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define shared variable varparentproc as widget-handle no-undo.
define variable fact-order-start like ub.stk-tot.fact-order no-undo.
define variable fact-order-end   like ub.stk-tot.fact-order no-undo.
define variable fact-order-min   like ub.stk-tot.fact-order no-undo.
define variable fact-order-max   like ub.stk-tot.fact-order no-undo.
define variable varh_caller-main as widget-handle no-undo.
define variable varsum-type-ot-line like ub.ot-line.sum-type no-undo.
define variable rdtaxcdvalue  as character initial ? no-undo.
define variable rdtaxcdtype   as character initial ? no-undo.
define buffer   rt_tax        for ub.tax.
define temp-table tt-kind-sum no-undo
field sum-kind as character format "x(15)"
field order as integer
field sum-start-base      like ub.stk-line.sum-base
field sum-start-rubl      like ub.stk-line.sum-base
field sum-end-base        like ub.stk-line.sum-base
field sum-end-rubl        like ub.stk-line.sum-base
field sum-start-base-sale like ub.stk-line.sum-base
field sum-start-rubl-sale like ub.stk-line.sum-base
field sum-end-base-sale   like ub.stk-line.sum-base
field sum-end-rubl-sale   like ub.stk-line.sum-base
index pi order
index sum-kind sum-kind.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure lastordr :
  define input  parameter parobj-type     as character no-undo .
  define input  parameter parobj-code     as integer   no-undo .
  define input  parameter paris-shift     as logical   no-undo .
  define input  parameter paris-shift-num as logical   no-undo .
  define input  parameter pardate         as date      no-undo .
  define input  parameter parshift-num    as integer   no-undo .
  define output parameter parfact-order   as decimal   no-undo .
  if paris-shift = no
  then do:
    find last ub.stk-tot no-lock
      where ub.stk-tot.obj-type    = parobj-type
        and ub.stk-tot.obj-code    = parobj-code
        and ub.stk-tot.fact-date <= pardate
        and ub.stk-tot.shift-num  = 0
      use-index fact-date
      no-error .
  end.
  else do:
    if paris-shift-num = no
    then do:
      find last ub.stk-tot no-lock
        where ub.stk-tot.obj-type    = parobj-type
          and ub.stk-tot.obj-code    = parobj-code
          and ub.stk-tot.shift-date <= pardate
          and ub.stk-tot.shift-num   > 0
        use-index shift-num
        no-error .
    end.
    else do:
      find last ub.stk-tot no-lock
        where ub.stk-tot.obj-type   = parobj-type
          and ub.stk-tot.obj-code   = parobj-code
          and ub.stk-tot.shift-date = pardate
          and ub.stk-tot.shift-num  <= parshift-num
          and ub.stk-tot.shift-num  > 0
        use-index shift-num
        no-error .
      if not available ub.stk-tot
      then do:
        find last ub.stk-tot no-lock
          where ub.stk-tot.obj-type   = parobj-type
            and ub.stk-tot.obj-code   = parobj-code
            and ub.stk-tot.shift-date < pardate
            and ub.stk-tot.shift-num  > 0
          use-index shift-num
          no-error .
      end.
    end.
  end.
  assign
    parfact-order = (if available ub.stk-tot then ub.stk-tot.fact-order else 0)
  .
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure dfactord:
define input  parameter parobj-type         like ub.clients.obj-type   no-undo.
define input  parameter parobj-code         like ub.clients.obj-code   no-undo.
define input  parameter paris-calend-day    as   logical            no-undo.
define input  parameter paris-shift-num     as   logical            no-undo.
define input  parameter pardate-start       as   date               no-undo.
define input  parameter pardate-end         as   date               no-undo.
define input  parameter parshift-start      as   integer            no-undo.
define input  parameter parshift-end        as   integer            no-undo.
define output parameter parfact-order-start like ub.stk-tot.fact-order no-undo.
define output parameter parfact-order-end   like ub.stk-tot.fact-order no-undo.
if paris-calend-day then do:
   run lastordr
       (input  parobj-type,
        input  parobj-code,
        input  no,
        input  ?,
        input  pardate-start - 1,
        input  ?,
        output parfact-order-start) no-error.
   if error-status:error then return error.
   run lastordr
       (input  parobj-type,
        input  parobj-code,
        input  no,
        input  ?,
        input  pardate-end,
        input  ?,
        output parfact-order-end) no-error.
   if error-status:error then return error.
end.
else do:
   if paris-shift-num then do:
      run lastordr
          (input  parobj-type,
           input  parobj-code,
           input  yes,
           input  yes,
           input  pardate-start,
           input  parshift-start - 1,
           output parfact-order-start) no-error.
      if error-status:error then return error.
      run lastordr
          (input  parobj-type,
           input  parobj-code,
           input  yes,
           input  yes,
           input  pardate-end,
           input  parshift-end,
           output parfact-order-end) no-error.
      if error-status:error then return error.
   end.
   else do:
      run lastordr
          (input  parobj-type,
           input  parobj-code,
           input  yes,
           input  no,
           input  pardate-start - 1,
           input  ?,
           output parfact-order-start) no-error.
      if error-status:error then return error.
      run lastordr
          (input  parobj-type,
           input  parobj-code,
           input  yes,
           input  no,
           input  pardate-end,
           input  ?,
           output parfact-order-end) no-error.
      if error-status:error then return error.
   end.
end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define temp-table tt-stk-line no-undo like ub.stk-line.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure stk-lnst:
define input  parameter parobj-type   like ub.clients.obj-type    no-undo.
define input  parameter parobj-code   like ub.clients.obj-code    no-undo.
define input  parameter parartic      like ub.goods.artic         no-undo.
define input  parameter parprod-type  like ub.goods.prod-type     no-undo.
define input  parameter parprod-code  like ub.goods.prod-code     no-undo.
define input  parameter parfact-order like ub.stk-line.fact-order no-undo.
define input  parameter parsum-type   like ub.stk-line.sum-type   no-undo.
define input  parameter parcat-id     like ub.stk-line.cat-id     no-undo.
define input  parameter paris-shift   as   logical             no-undo.
define output parameter table for tt-stk-line.
if paris-shift then do:
  find last ub.stk-line where ub.stk-line.obj-type    = parobj-type   and
                           ub.stk-line.obj-code    = parobj-code   and
                           ub.stk-line.artic       = parartic      and
                           ub.stk-line.prod-type   = parprod-type  and
                           ub.stk-line.prod-code   = parprod-code  and
                           ub.stk-line.fact-order <= parfact-order and
                           ub.stk-line.sum-type    = parsum-type   and
                           ub.stk-line.cat-id      = parcat-id     and
                           ub.stk-line.shift-date <> ?             use-index category no-lock no-error.
end.
else do:
  find last ub.stk-line where ub.stk-line.obj-type    = parobj-type   and
                           ub.stk-line.obj-code    = parobj-code   and
                           ub.stk-line.artic       = parartic      and
                           ub.stk-line.prod-type   = parprod-type  and
                           ub.stk-line.prod-code   = parprod-code  and
                           ub.stk-line.fact-order <= parfact-order and
                           ub.stk-line.sum-type    = parsum-type   and
                           ub.stk-line.cat-id      = parcat-id     and
                           ub.stk-line.shift-date  = ?             use-index category no-lock no-error.
end.
if available ub.stk-line then do:
   create tt-stk-line.
   buffer-copy ub.stk-line to tt-stk-line.
end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table start-stk-line no-undo like ub.stk-line.
define temp-table end-stk-line   no-undo like ub.stk-line.
procedure stk-lnrv:
define input  parameter parobj-type         like ub.clients.obj-type       no-undo.
define input  parameter parobj-code         like ub.clients.obj-code       no-undo.
define input  parameter parartic            like ub.goods.artic            no-undo.
define input  parameter parprod-type        like ub.goods.prod-type        no-undo.
define input  parameter parprod-code        like ub.goods.prod-code        no-undo.
define input  parameter parfact-order-start like ub.stk-line.fact-order no-undo.
define input  parameter parfact-order-end   like ub.stk-line.fact-order no-undo.
define input  parameter parsum-type         like ub.stk-line.sum-type   no-undo.
define input  parameter parcat-id           like ub.stk-line.cat-id     no-undo.
define input  parameter paris-shift         as   logical                no-undo.
define output parameter table for tt-stk-line.
define variable i                as integer no-undo.
define variable varqnty-doc-type as integer no-undo.
define variable varsum-type like ub.stk-line.sum-type no-undo.
do on error undo, return error return-value :
assign varqnty-doc-type = num-entries('ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U).
do i = 1 to varqnty-doc-type:
   assign varsum-type = parsum-type + ENTRY(i, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U).
if paris-shift then do:
  for each start-stk-line:                                                                                        delete start-stk-line.                                                                                  end.                                                                                                                find last ub.stk-line where ub.stk-line.obj-type    = parobj-type                  and                                                             ub.stk-line.obj-code    = parobj-code                  and                                                             ub.stk-line.artic       = parartic                     and                                                             ub.stk-line.prod-type   = parprod-type                 and                                                             ub.stk-line.prod-code   = parprod-code                 and                                                             ub.stk-line.fact-order <= parfact-order-start  and                                                             ub.stk-line.sum-type    = varsum-type                  and                                                             ub.stk-line.cat-id      = parcat-id                    and                                                             ub.stk-line.shift-date <> ?                                                                                                    use-index category no-lock no-error .                                                       if available ub.stk-line then do:                                                                                         create start-stk-line.                                                                                      buffer-copy ub.stk-line to start-stk-line.                                                                  end.
end.
else do:
  for each start-stk-line:                                                                                        delete start-stk-line.                                                                                  end.                                                                                                                find last ub.stk-line where ub.stk-line.obj-type    = parobj-type                  and                                                             ub.stk-line.obj-code    = parobj-code                  and                                                             ub.stk-line.artic       = parartic                     and                                                             ub.stk-line.prod-type   = parprod-type                 and                                                             ub.stk-line.prod-code   = parprod-code                 and                                                             ub.stk-line.fact-order <= parfact-order-start  and                                                             ub.stk-line.sum-type    = varsum-type                  and                                                             ub.stk-line.cat-id      = parcat-id                    and                                                             ub.stk-line.shift-date = ?                                                                                                    use-index category no-lock no-error .                                                       if available ub.stk-line then do:                                                                                         create start-stk-line.                                                                                      buffer-copy ub.stk-line to start-stk-line.                                                                  end.
end.
if paris-shift then do:
  for each end-stk-line:                                                                                        delete end-stk-line.                                                                                  end.                                                                                                                find last ub.stk-line where ub.stk-line.obj-type    = parobj-type                  and                                                             ub.stk-line.obj-code    = parobj-code                  and                                                             ub.stk-line.artic       = parartic                     and                                                             ub.stk-line.prod-type   = parprod-type                 and                                                             ub.stk-line.prod-code   = parprod-code                 and                                                             ub.stk-line.fact-order <= parfact-order-end  and                                                             ub.stk-line.sum-type    = varsum-type                  and                                                             ub.stk-line.cat-id      = parcat-id                    and                                                             ub.stk-line.shift-date <> ?                                                                                                    use-index category no-lock no-error .                                                       if available ub.stk-line then do:                                                                                         create end-stk-line.                                                                                      buffer-copy ub.stk-line to end-stk-line.                                                                  end.
end.
else do:
  for each end-stk-line:                                                                                        delete end-stk-line.                                                                                  end.                                                                                                                find last ub.stk-line where ub.stk-line.obj-type    = parobj-type                  and                                                             ub.stk-line.obj-code    = parobj-code                  and                                                             ub.stk-line.artic       = parartic                     and                                                             ub.stk-line.prod-type   = parprod-type                 and                                                             ub.stk-line.prod-code   = parprod-code                 and                                                             ub.stk-line.fact-order <= parfact-order-end  and                                                             ub.stk-line.sum-type    = varsum-type                  and                                                             ub.stk-line.cat-id      = parcat-id                    and                                                             ub.stk-line.shift-date = ?                                                                                                    use-index category no-lock no-error .                                                       if available ub.stk-line then do:                                                                                         create end-stk-line.                                                                                      buffer-copy ub.stk-line to end-stk-line.                                                                  end.
end.
if
   available end-stk-line   and
   (not available start-stk-line or
   start-stk-line.fact-order <> end-stk-line.fact-order) then do:
      create tt-stk-line.
      assign
      tt-stk-line.obj-type       = parobj-type
      tt-stk-line.obj-code       = parobj-code
      tt-stk-line.artic          = parartic
      tt-stk-line.prod-type      = parprod-type
      tt-stk-line.prod-code      = parprod-code
      tt-stk-line.sum-type       = varsum-type
      tt-stk-line.cat-id         = parcat-id
      tt-stk-line.fact-qnty      = (if available end-stk-line then (end-stk-line.fact-qnty      - (if available start-stk-line then start-stk-line.fact-qnty      else 0)) else 0)
      tt-stk-line.sum-base       = (if available end-stk-line then (end-stk-line.sum-base       - (if available start-stk-line then start-stk-line.sum-base       else 0)) else 0)
      tt-stk-line.sum-rubl       = (if available end-stk-line then (end-stk-line.sum-rubl       - (if available start-stk-line then start-stk-line.sum-rubl       else 0)) else 0)
      tt-stk-line.SLT-base       = (if available end-stk-line then (end-stk-line.SLT-base       - (if available start-stk-line then start-stk-line.SLT-base       else 0)) else 0)
      tt-stk-line.SLT-rubl       = (if available end-stk-line then (end-stk-line.SLT-rubl       - (if available start-stk-line then start-stk-line.SLT-rubl       else 0)) else 0)
      tt-stk-line.VAT-base       = (if available end-stk-line then (end-stk-line.VAT-base       - (if available start-stk-line then start-stk-line.VAT-base       else 0)) else 0)
      tt-stk-line.VAT-rubl       = (if available end-stk-line then (end-stk-line.VAT-rubl       - (if available start-stk-line then start-stk-line.VAT-rubl       else 0)) else 0)
      tt-stk-line.excise-base    = (if available end-stk-line then (end-stk-line.excise-base    - (if available start-stk-line then start-stk-line.excise-base    else 0)) else 0)
      tt-stk-line.excise-rubl    = (if available end-stk-line then (end-stk-line.excise-rubl    - (if available start-stk-line then start-stk-line.excise-rubl    else 0)) else 0)
      tt-stk-line.other-base     = (if available end-stk-line then (end-stk-line.other-base     - (if available start-stk-line then start-stk-line.other-base     else 0)) else 0)
      tt-stk-line.other-rubl     = (if available end-stk-line then (end-stk-line.other-rubl     - (if available start-stk-line then start-stk-line.other-rubl     else 0)) else 0)
      tt-stk-line.road-tax-base  = (if available end-stk-line then (end-stk-line.road-tax-base  - (if available start-stk-line then start-stk-line.road-tax-base  else 0)) else 0)
      tt-stk-line.road-tax-rubl  = (if available end-stk-line then (end-stk-line.road-tax-rubl  - (if available start-stk-line then start-stk-line.road-tax-rubl  else 0)) else 0)
      tt-stk-line.transport-base = (if available end-stk-line then (end-stk-line.transport-base - (if available start-stk-line then start-stk-line.transport-base else 0)) else 0)
      tt-stk-line.transport-rubl = (if available end-stk-line then (end-stk-line.transport-rubl - (if available start-stk-line then start-stk-line.transport-rubl else 0)) else 0).
   end.
end.
end.
end procedure.
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure tax-name:
define input  parameter pardef-tax  as character           no-undo.
define output parameter parname-tax as character initial ? no-undo.
define buffer bf_tax for ub.tax.
do on error undo, return error :
   case pardef-tax:
      when 'vat':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('1':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '1':U(не задействован)".
      end.
      when 'slt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('2':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '2':U(не задействован)".
      end.
      when 'rdt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('3':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '3':U(не задействован)".
      end.
      when 'exc':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('4':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '4':U(не задействован)".
      end.
      otherwise do:
         return error "Задан неверный параметр " + pardef-tax + " .".
      end.
   end case.
end.
end procedure.
define variable rdtaxname as character no-undo.
define variable varsum-start like ub.stk-line.sum-base no-undo.
define variable varsum-end like ub.stk-line.sum-base no-undo.
define variable varsum-start-sale like ub.stk-line.sum-base no-undo.
define variable varsum-end-sale like ub.stk-line.sum-base no-undo.
define variable varorder as integer no-undo.
define variable varroad-tax like ub.ot-line.sum-base no-undo.
define variable varroad-tax-doc like ub.ot-line.sum-base no-undo.
RUN set-attribute-list (
    'Keys-Accepted = "",
     Keys-Supplied = ""':U).
FUNCTION func-excise RETURNS DECIMAL
  ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.
FUNCTION func-excise-doc RETURNS DECIMAL
  ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.
FUNCTION func-other RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.
FUNCTION func-other-doc RETURNS DECIMAL
 ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.
FUNCTION func-price-doc RETURNS DECIMAL
( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.
FUNCTION func-price-sale RETURNS DECIMAL
( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.
FUNCTION func-road-tax RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.
FUNCTION func-road-tax-doc RETURNS DECIMAL
 ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.
FUNCTION func-slt RETURNS DECIMAL
 ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.
FUNCTION func-slt-doc RETURNS DECIMAL
( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.
FUNCTION func-sum RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.
FUNCTION func-sum-doc RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.
FUNCTION func-sum-end RETURNS DECIMAL
  ( buffer bf_tt-kind-sum for tt-kind-sum )  FORWARD.
FUNCTION func-sum-end-sale RETURNS DECIMAL
  ( buffer bf_tt-kind-sum for tt-kind-sum )  FORWARD.
FUNCTION func-sum-sale RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.
FUNCTION func-sum-start RETURNS DECIMAL
  ( buffer bf_tt-kind-sum for tt-kind-sum )  FORWARD.
FUNCTION func-sum-start-sale RETURNS DECIMAL
  ( buffer bf_tt-kind-sum for tt-kind-sum )  FORWARD.
FUNCTION func-transport RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.
FUNCTION func-transport-doc RETURNS DECIMAL
  ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.
FUNCTION func-vat RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.
FUNCTION func-vat-doc RETURNS DECIMAL
    ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.
DEFINE VARIABLE varqnty-end AS DECIMAL FORMAT "->>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE varqnty-start AS DECIMAL FORMAT "->>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98 BY 1.83.
DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE .38 BY 1.58.
DEFINE RECTANGLE RECT-13
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE .13 BY 1.88.
DEFINE QUERY b-kind-type FOR
      tt-kind-sum SCROLLING.
DEFINE QUERY BROWSE-1 FOR
      acc-stk-line SCROLLING.
DEFINE BROWSE b-kind-type
  QUERY b-kind-type DISPLAY
      tt-kind-sum.sum-kind column-label " "
      func-sum-start-sale (buffer tt-kind-sum) @ varsum-start-sale column-label "продажные" format " ->>>,>>>,>>>,>>9.99"
      func-sum-start (buffer tt-kind-sum) @ varsum-start column-label "учетные" format "->>,>>>>,>>>,>>9.99"
      func-sum-end-sale (buffer tt-kind-sum) @ varsum-end-sale column-label "продажные" format " ->>>,>>>,>>>,>>9.99"
      func-sum-end (buffer tt-kind-sum) @ varsum-end column-label "учетные" format "->>>,>>>,>>>,>>9.99"
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 98.25 BY 3.92.
DEFINE BROWSE BROWSE-1
  QUERY BROWSE-1 DISPLAY
      acc-stk-line.ext-doc-type-full COLUMN-LABEL "Оборот по док." FORMAT "X(20)"
      acc-stk-line.fact-qnty COLUMN-LABEL "Количество"
      func-sum-doc (buffer acc-stk-line) FORMAT "->>,>>>,>>>,>>9.99" COLUMN-LABEL "Сумма(по док)"
      func-sum (buffer acc-stk-line) FORMAT "->>,>>>,>>>,>>9.99" COLUMN-LABEL "Сумма(учет)"
      func-sum-sale (buffer acc-stk-line) FORMAT "->>,>>>,>>>,>>9.99" COLUMN-LABEL "Сумма(прод)"
      func-other-doc(buffer acc-stk-line) FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "Скидка(Проч.расх.)(по док)"
      func-VAT-doc (buffer acc-stk-line) FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "НДС(по док)"
      func-SLT-doc (buffer acc-stk-line) FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "НП(по док)"
      func-VAT (buffer acc-stk-line) FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "НДС(учет)"
      func-SLT (buffer acc-stk-line) FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "НП(учет)"
      func-excise-doc (buffer acc-stk-line) FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "Акциз(по док)"
      func-excise (buffer acc-stk-line) FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "Акциз(учет)"
      func-road-tax-doc (buffer acc-stk-line) @ varroad-tax-doc   FORMAT "->,>>>,>>>,>>9.99"
      func-road-tax (buffer acc-stk-line) @ varroad-tax       FORMAT "->,>>>,>>>,>>9.99"
      func-transport-doc (buffer acc-stk-line)  FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "Транспортные расходы(по док)"
      func-transport (buffer acc-stk-line)      FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "Транспортные расходы"
      func-other (buffer acc-stk-line) FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "Проч.расх.(Скидка)(учет)"
      func-price-doc (buffer acc-stk-line) FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "Сумма/кол-во(по док)"
      func-price-sale (buffer acc-stk-line) FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "Сумма/кол-во(прод)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.25 BY 12.25.
DEFINE FRAME F-Main
     varqnty-start AT ROW 1.79 COL 27.88 COLON-ALIGNED NO-LABEL
     varqnty-end AT ROW 1.79 COL 72.75 COLON-ALIGNED NO-LABEL
     b-kind-type AT ROW 2.96 COL 1
     BROWSE-1 AT ROW 6.96 COL 1
     "Остаток на конец периода" VIEW-AS TEXT
          SIZE 24.63 BY .67 AT ROW 1.04 COL 69
          FGCOLOR 3
     "Остаток на начало периода" VIEW-AS TEXT
          SIZE 25.88 BY .67 AT ROW 1.04 COL 25.5
          FGCOLOR 3
     "  Количество" VIEW-AS TEXT
          SIZE 15.38 BY 1 AT ROW 1.83 COL 1.63
          FGCOLOR 3
     RECT-13 AT ROW 1 COL 56.38
     RECT-11 AT ROW 1.13 COL 1
     RECT-12 AT ROW 1.25 COL 17.75
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE .
DEFINE VARIABLE adm-sts           AS LOGICAL NO-UNDO.
DEFINE VARIABLE adm-brs-in-update AS LOGICAL NO-UNDO INIT no.
DEFINE VARIABLE adm-brs-initted   AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-object-hdl       AS HANDLE NO-UNDO.
DEFINE VAR adm-query-opened        AS LOGICAL NO-UNDO INIT NO.
DEFINE VAR adm-row-avail-state     AS LOGICAL NO-UNDO INIT ?.
DEFINE VAR adm-initial-lock        AS CHARACTER NO-UNDO INIT "NO-LOCK":U.
DEFINE VAR adm-new-record          AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-updating-record     AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-check-modified-all  AS LOGICAL NO-UNDO INIT no.
DEFINE NEW GLOBAL SHARED VAR adm-broker-hdl    AS HANDLE  NO-UNDO.
      adm-object-hdl = FRAME F-Main:HANDLE.
RUN ensure-broker.
THIS-PROCEDURE:ADM-DATA =
     'ADM1.1~`':U +
     'SmartObject~`':U +
     '~`':U +
     'YES~`':U +
     '~`':U +
     'tt-kind-sum acc-stk-line~`':U +
     '~`':U +
     (IF adm-object-hdl = ? THEN "":U ELSE STRING(adm-object-hdl))
        + "~`":U +
     'Initial-Lock,Hide-on-Init,Disable-on-Init,Key-Name,Layout,Create-On-Add,SortBy-Case~`':U +
     'Record-Source,Record-Target,TableIO-Target~`':U +
     '~`':U +
     '~`~`~`~`~`~`~`~`~`~`~`':U +
     IF THIS-PROCEDURE:ADM-DATA = "":U OR THIS-PROCEDURE:ADM-DATA = ?
         THEN "^^":U
     ELSE "^":U + ENTRY(2, THIS-PROCEDURE:ADM-DATA, "^":U) +
          "^":U + ENTRY(3, THIS-PROCEDURE:ADM-DATA, "^":U).
PROCEDURE adm-apply-entry :
  RUN broker-apply-entry IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-destroy :
 RUN broker-destroy IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-disable :
    DISABLE RECT-13 RECT-11 RECT-12 b-kind-type BROWSE-1 WITH FRAME F-Main.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
      RUN adm/support/browserd.w (INPUT THIS-PROCEDURE).
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN RECT-13 RECT-11 RECT-12 b-kind-type BROWSE-1 WITH FRAME F-Main.
    RUN enable_UI IN THIS-PROCEDURE NO-ERROR.
    RUN set-attribute-list ('ENABLED=yes':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-exit :
     RUN notify ('exit':U).
  RETURN.
END PROCEDURE.
PROCEDURE adm-hide :
  RUN broker-hide IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-initialize :
  RUN broker-initialize IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-show-errors :
    DEFINE VARIABLE        cntr                  AS INTEGER   NO-UNDO.
    DO cntr = 1 TO ERROR-STATUS:NUM-MESSAGES:
        MESSAGE ERROR-STATUS:GET-MESSAGE(cntr).
    END.
    RETURN.
END PROCEDURE.
PROCEDURE adm-UIB-mode :
  RUN broker-UIB-mode IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-view :
  RUN broker-view IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE dispatch :
    DEFINE INPUT PARAMETER p-method-name    AS CHARACTER NO-UNDO.
    RUN broker-dispatch IN adm-broker-hdl
        (THIS-PROCEDURE, p-method-name) NO-ERROR.
    IF RETURN-VALUE = "ADM-ERROR":U THEN RETURN "ADM-ERROR":U.
END PROCEDURE.
PROCEDURE ensure-broker :
RUN get-attribute IN adm-broker-hdl ('TYPE':U) NO-ERROR.
IF RETURN-VALUE NE "ADM-Broker":U THEN
DO:
    RUN adm/objects/broker.p PERSISTENT set adm-broker-hdl.
    RUN set-broker-owner IN adm-broker-hdl (THIS-PROCEDURE).
END.
END PROCEDURE.
PROCEDURE get-attribute :
  DEFINE INPUT PARAMETER p-attr-name    AS CHARACTER NO-UNDO.
  RUN broker-get-attribute IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-attr-name) NO-ERROR.
  RETURN RETURN-VALUE.
END PROCEDURE.
PROCEDURE get-attribute-list :
  DEFINE OUTPUT PARAMETER p-attr-list AS CHARACTER NO-UNDO.
  RUN broker-get-attribute-list IN adm-broker-hdl
      (INPUT THIS-PROCEDURE,
       INPUT ?,
       OUTPUT p-attr-list) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE new-state :
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
  RUN broker-new-state IN adm-broker-hdl (THIS-PROCEDURE, p-state) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE notify :
  DEFINE INPUT PARAMETER p-method AS CHARACTER NO-UNDO.
  RUN broker-notify IN adm-broker-hdl (THIS-PROCEDURE, p-method) NO-ERROR.
  IF RETURN-VALUE = "ADM-ERROR":U THEN
      RETURN "ADM-ERROR":U.
  RETURN.
END PROCEDURE.
PROCEDURE set-attribute-list :
  DEFINE INPUT PARAMETER p-attr-list    AS CHARACTER NO-UNDO.
  RUN ensure-broker.
  RUN broker-set-attribute-list IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-attr-list) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE set-position :
    DEFINE INPUT PARAMETER p-row    AS DECIMAL NO-UNDO.
    DEFINE INPUT PARAMETER p-col    AS DECIMAL NO-UNDO.
    IF VALID-HANDLE(adm-object-hdl) THEN
    DO:
      ASSIGN adm-object-hdl:ROW    =   p-row
             adm-object-hdl:COLUMN =   p-col.
    END.
    RETURN.
END PROCEDURE.
  DEFINE VARIABLE adm-first-table         AS ROWID NO-UNDO.
  DEFINE VARIABLE adm-second-table        AS ROWID NO-UNDO.
  DEFINE VARIABLE adm-third-table         AS ROWID NO-UNDO.
  DEFINE VARIABLE adm-adding-record       AS LOGICAL NO-UNDO INIT no.
  DEFINE VARIABLE adm-return-status       AS LOGICAL   NO-UNDO.
  DEFINE VARIABLE adm-first-prev-rowid    AS ROWID     NO-UNDO.
  DEFINE VARIABLE adm-second-prev-rowid   AS ROWID     NO-UNDO.
  DEFINE VARIABLE adm-third-prev-rowid    AS ROWID     NO-UNDO.
  DEFINE VARIABLE adm-first-tmpl-recid    AS RECID     NO-UNDO INIT ?.
  DEFINE VARIABLE adm-second-tmpl-recid   AS RECID     NO-UNDO INIT ?.
  DEFINE VARIABLE adm-third-tmpl-recid    AS RECID     NO-UNDO INIT ?.
  DEFINE VARIABLE adm-index-pos           AS INTEGER   NO-UNDO.
  DEFINE VARIABLE adm-query-empty         AS LOGICAL   NO-UNDO.
  DEFINE VARIABLE adm-create-complete     AS LOGICAL   NO-UNDO.
  DEFINE VARIABLE adm-create-on-add       AS LOGICAL   NO-UNDO INIT ?.
  DEFINE VARIABLE group-assign-target     AS LOGICAL   NO-UNDO INIT ?.
  DEFINE VARIABLE group-target-list       AS CHARACTER NO-UNDO INIT ?.
  IF "":U = "":U THEN
    RUN modify-list-attribute IN adm-broker-hdl
      (THIS-PROCEDURE, "REMOVE":U, "SUPPORTED-LINKS":U, "TABLEIO-TARGET":U).
  RUN use-create-on-add(?).
PROCEDURE adm-add-record :
    MESSAGE "Object ":U THIS-PROCEDURE:FILE-NAME
       "must have at least one Enabled Table to perform Add.":U
       VIEW-AS ALERT-BOX ERROR.
    RETURN.
END PROCEDURE.
PROCEDURE adm-assign-record :
 MESSAGE
       "Object ":U THIS-PROCEDURE:FILE-NAME
         "must have at least one Enabled Table to perform Assign.":U
           VIEW-AS ALERT-BOX ERROR.
   RETURN.
  END PROCEDURE.
PROCEDURE adm-assign-statement :
  RETURN.
END PROCEDURE.
PROCEDURE adm-cancel-record :
   RETURN.
  END PROCEDURE.
PROCEDURE adm-copy-record :
    MESSAGE "Object ":U THIS-PROCEDURE:FILE-NAME
     "must have at least one Enabled Table to perform Copy.":U
       VIEW-AS ALERT-BOX ERROR.
    RETURN.
END PROCEDURE.
PROCEDURE adm-create-record :
   RETURN.
END PROCEDURE.
PROCEDURE adm-current-changed :
  RETURN.
END PROCEDURE.
PROCEDURE adm-delete-record :
 MESSAGE
       "Object ":U THIS-PROCEDURE:FILE-NAME
         "must have at least one Enabled Table to perform Delete.":U
           VIEW-AS ALERT-BOX ERROR.
    RUN dispatch IN THIS-PROCEDURE ('apply-entry':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-disable-fields :
      RUN notify ('disable-fields, GROUP-ASSIGN-TARGET':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-enable-fields :
    RETURN.
END PROCEDURE.
PROCEDURE adm-end-update :
  RETURN.
END PROCEDURE.
PROCEDURE adm-reset-record :
    RETURN.
END PROCEDURE.
PROCEDURE adm-update-record :
    MESSAGE
      "Object ":U THIS-PROCEDURE:FILE-NAME
        "must have at least one Enabled Table to perform Update.":U
          VIEW-AS ALERT-BOX ERROR.
   RETURN.
END PROCEDURE.
PROCEDURE check-modified :
DEFINE INPUT PARAMETER check-state AS CHARACTER NO-UNDO.
DEFINE VARIABLE curr-widget       AS HANDLE      NO-UNDO.
DEFINE VARIABLE container-hdl-str AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i                 AS INTEGER     NO-UNDO.
  IF check-state = "check":U THEN
  DO:
    RUN get-link-handle IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT 'GROUP-ASSIGN-TARGET':U,
         OUTPUT group-target-list).
    IF group-target-list NE "":U THEN
    DO i = 1 TO NUM-ENTRIES(group-target-list):
      curr-widget = WIDGET-HANDLE(ENTRY(i, group-target-list)).
      RUN check-modified IN curr-widget ('group-check':U).
      IF RETURN-VALUE NE "":U THEN
      DO:
        RUN check-modified-message(RETURN-VALUE).
        RETURN "":U.
      END.
    END.
  END.
  RETURN "":U.
END PROCEDURE.
PROCEDURE check-modified-message :
  DEFINE INPUT PARAMETER p-changed-table AS CHARACTER NO-UNDO.
     RUN request-attribute IN adm-broker-hdl (THIS-PROCEDURE,
        'CONTAINER-SOURCE':U, 'HIDDEN':U).
     IF RETURN-VALUE = "YES":U THEN
        RUN notify ('view,CONTAINER-SOURCE':U).
     MESSAGE IF p-changed-table NE ? THEN
        SUBSTITUTE ("Current &1 record has been changed.", p-changed-table)
        ELSE "Current values have been changed."
        SKIP "  Do you wish to save those changes?"
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE ANS AS LOGICAL.
     IF ANS THEN
     DO:
        IF group-assign-target THEN
          RUN notify('update-record,GROUP-ASSIGN-SOURCE':U).
        ELSE RUN dispatch('update-record':U).
        IF RETURN-VALUE = "ADM-ERROR":U THEN
        DO:
            MESSAGE "Changes to the previous record were not saved."
              VIEW-AS ALERT-BOX ERROR.
            IF group-assign-target THEN
              RUN notify('cancel-record,GROUP-ASSIGN-SOURCE':U).
            ELSE RUN dispatch ('cancel-record':U).
        END.
     END.
     ELSE DO:
       IF group-assign-target THEN
          RUN notify('cancel-record,GROUP-ASSIGN-SOURCE':U).
       ELSE RUN dispatch('cancel-record':U).
     END.
     RETURN.
END PROCEDURE.
PROCEDURE get-rowid :
    DEFINE OUTPUT PARAMETER p-table           AS ROWID NO-UNDO.
    ASSIGN
    p-table   =   adm-first-table.
    RETURN.
END PROCEDURE.
PROCEDURE init-group-assign :
    RUN request-attribute IN adm-broker-hdl
      (THIS-PROCEDURE, 'GROUP-ASSIGN-SOURCE':U, 'ENABLED-TABLES':U).
    IF LOOKUP("":U, RETURN-VALUE, " ":U) NE 0 THEN
      group-assign-target = yes.
    ELSE group-assign-target = no.
    RETURN.
END PROCEDURE.
PROCEDURE set-editors :
    DEFINE INPUT PARAMETER p-field-setting  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE curr-widget             AS HANDLE    NO-UNDO.
    DEFINE VARIABLE read-only-list          AS CHARACTER NO-UNDO INIT "":U.
    ASSIGN curr-widget = FRAME F-Main:CURRENT-ITERATION.
    ASSIGN curr-widget = curr-widget:FIRST-CHILD.
    DO WHILE VALID-HANDLE (curr-widget):
        IF curr-widget:TYPE = "EDITOR":U AND curr-widget:TABLE NE ? AND
           curr-widget:HIDDEN = no THEN DO:
          CASE p-field-setting:
            WHEN "INITIALIZE":U THEN
            DO:
              IF curr-widget:READ-ONLY = yes THEN read-only-list =
                  read-only-list +
                    (IF read-only-list NE "":U THEN ",":U ELSE "":U) +
                     STRING(curr-widget).
            END.
            WHEN "DISABLE":U OR
            WHEN "ENABLE":U THEN
            DO:
                curr-widget:SENSITIVE = yes.
                RUN get-attribute ('Read-Only-Editors':U).
                IF RETURN-VALUE = ? OR
                  LOOKUP (STRING(curr-widget), RETURN-VALUE) EQ 0 THEN
                    curr-widget:READ-ONLY =
                      IF p-field-setting = "ENABLE":U THEN no ELSE yes.
            END.
            WHEN "CLEAR":U THEN
                curr-widget:SCREEN-VALUE = "":U.
          END CASE.
        END.
        ASSIGN curr-widget = curr-widget:NEXT-SIBLING.
    END.
    IF p-field-setting = "INITIALIZE":U AND read-only-list NE "":U THEN
      RUN set-attribute-list ('Read-Only-Editors = "':U + read-only-list
        + '"':U).
    RETURN.
END PROCEDURE.
PROCEDURE use-check-modified-all :
 DEFINE INPUT PARAMETER p-attr-value AS CHARACTER NO-UNDO.
  ASSIGN adm-check-modified-all = IF p-attr-value = "YES":U THEN yes ELSE no.
  RETURN.
END PROCEDURE.
PROCEDURE use-create-on-add :
DEFINE INPUT PARAMETER p-attr-value AS CHARACTER NO-UNDO.
   RETURN.
END PROCEDURE.
PROCEDURE use-initial-lock :
  DEFINE INPUT PARAMETER p-attr-value AS CHARACTER NO-UNDO.
  ASSIGN adm-initial-lock = p-attr-value.
  RETURN.
END PROCEDURE.
PROCEDURE adm-display-fields :
      IF AVAILABLE tt-kind-sum THEN
          DISPLAY tt-kind-sum.sum-kind func-sum-start-sale (buffer tt-kind-sum) @ varsum-start-sale func-sum-start (buffer tt-kind-sum) @ varsum-start func-sum-end-sale (buffer tt-kind-sum) @ varsum-end-sale func-sum-end (buffer tt-kind-sum) @ varsum-end WITH BROWSE b-kind-type
            NO-ERROR.
      DISPLAY UNLESS-HIDDEN varqnty-start varqnty-end
          WITH FRAME F-Main NO-ERROR.
    RUN check-modified IN THIS-PROCEDURE ('clear':U) NO-ERROR.
    RETURN.
END PROCEDURE.
PROCEDURE adm-open-query :
            OPEN QUERY b-kind-type FOR EACH tt-kind-sum NO-LOCK.
        adm-query-opened = yes.
        IF NUM-RESULTS("b-kind-type":U) = 0 THEN
            RUN new-state ('no-record-available,SELF':U).
        ELSE DO:
            RUN new-state ('record-available,SELF':U).
            RUN new-state ('first-record,SELF':U).
        END.
        IF NOT adm-updating-record THEN
            RUN dispatch IN THIS-PROCEDURE ('row-changed':U).
  RETURN.
END PROCEDURE.
PROCEDURE adm-row-changed :
      IF VALID-HANDLE(adm-object-hdl) THEN
        RUN dispatch IN THIS-PROCEDURE ('display-fields':U).
      RUN notify ('row-available':U).
      RETURN.
END PROCEDURE.
PROCEDURE reposition-query :
    DEFINE INPUT PARAMETER p-requestor-hdl     AS HANDLE NO-UNDO.
    DEFINE VARIABLE table-name                 AS ROWID NO-UNDO.
    RUN get-rowid IN p-requestor-hdl (OUTPUT table-name).
    IF table-name <> ? THEN
        REPOSITION b-kind-type TO ROWID table-name NO-ERROR.
    RUN set-attribute-list ('REPOSITION-PENDING = NO':U).
    RETURN.
END PROCEDURE.
  adm-sts = b-kind-type:SET-REPOSITIONED-ROW
    (b-kind-type:DOWN,"CONDITIONAL":U).
  RUN set-attribute-list ('FIELDS-ENABLED=no,ADM-NEW-RECORD=no':U).
PROCEDURE set-size :
  DEFINE INPUT PARAMETER pd_height AS DECIMAL NO-UNDO.
  DEFINE INPUT PARAMETER pd_width  AS DECIMAL NO-UNDO.
  DEFINE VARIABLE hBrowse     AS HANDLE           NO-UNDO.
  DEFINE VARIABLE hFieldGroup AS HANDLE           NO-UNDO.
  DEFINE VARIABLE hFrame      AS HANDLE           NO-UNDO.
  DEFINE VARIABLE htmpWidget  AS HANDLE           NO-UNDO.
  DEFINE VARIABLE otherWidget AS LOGICAL          NO-UNDO.
  ASSIGN pd_height = MAX(pd_height, 2.0)
         pd_width  = MAX(pd_width, 2.0)
         hBrowse     = b-kind-type:HANDLE IN FRAME F-Main
         hFieldGroup = hBrowse:PARENT
         htmpWidget  = hFieldGroup:FIRST-CHILD
         hFrame      = hFieldGroup:PARENT.
  Search-For-Siblings:
  REPEAT WHILE VALID-HANDLE(htmpWidget):
    IF htmpWidget NE hBrowse THEN DO:
      IF htmpWidget:TYPE NE "BUTTON" OR
         htmpWidget:X    NE 4 OR
         htmpWidget:Y    NE 4 THEN DO:
        RETURN.
      END.
    END.
    htmpWidget = htmpWidget:NEXT-SIBLING.
  END.
  IF pd_width < hBrowse:WIDTH THEN
    ASSIGN hBrowse:WIDTH = pd_width
           hFrame:WIDTH  = pd_width     NO-ERROR.
  ELSE
    ASSIGN hFrame:WIDTH  = pd_width
           hBrowse:WIDTH = pd_width     NO-ERROR.
  IF pd_height < hBrowse:HEIGHT THEN
    ASSIGN hBrowse:HEIGHT = pd_height
           hFrame:HEIGHT  = pd_height     NO-ERROR.
  ELSE
    ASSIGN hFrame:HEIGHT  = pd_height
           hBrowse:HEIGHT = pd_height     NO-ERROR.
END PROCEDURE.
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.
ASSIGN
       BROWSE-1:NUM-LOCKED-COLUMNS IN FRAME F-Main     = 2.
ON END-ERROR OF FRAME F-Main
DO:
  return no-apply.
END.
ON ENDKEY OF FRAME F-Main
DO:
    return no-apply.
END.
ON MOUSE-SELECT-DBLCLICK OF BROWSE-1 IN FRAME F-Main
DO:
  run set-attribute-list ('varext-doc-type=' + string(acc-stk-line.ext-doc-type)).
  run notify ('read_doc-type,doctype-target':u).
END.
if not this-procedure :persistent
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при запуске процедуры" skip
    "Данную процедуру следует запускать только с параметром persistent" skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in varparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
run tax-name ('rdt':U, output rdtaxname).
assign varroad-tax-doc :label in browse browse-1 = rdtaxname
       varroad-tax     :label in browse browse-1 = rdtaxname.
PROCEDURE adm-row-available :
  DEFINE VARIABLE tbl-list           AS CHARACTER INIT "":U NO-UNDO.
  DEFINE VARIABLE rowid-list         AS CHARACTER NO-UNDO.
  DEFINE VARIABLE row-avail-cntr     AS INTEGER INIT 0 NO-UNDO.
  DEFINE VARIABLE row-avail-rowid    AS ROWID NO-UNDO.
  DEFINE VARIABLE row-avail-enabled  AS LOGICAL NO-UNDO.
  DEFINE VARIABLE link-handle        AS CHARACTER NO-UNDO.
  DEFINE VARIABLE record-source-hdl  AS HANDLE NO-UNDO.
  DEFINE VARIABLE different-row      AS LOGICAL NO-UNDO INIT no.
  DEFINE VARIABLE key-name           AS CHARACTER INIT ? NO-UNDO.
  DEFINE VARIABLE key-value          AS CHARACTER INIT ? NO-UNDO.
  RUN check-modified IN THIS-PROCEDURE ('check':U) NO-ERROR.
  IF adm-updating-record THEN RETURN.
  RUN get-attribute ('FIELDS-ENABLED':U).
  row-avail-enabled = IF RETURN-VALUE = "YES":U THEN yes ELSE no.
  RUN get-link-handle IN adm-broker-hdl (THIS-PROCEDURE, 'RECORD-SOURCE':U,
      OUTPUT link-handle) NO-ERROR.
  IF link-handle = "":U THEN
      RETURN.
  ASSIGN record-source-hdl = WIDGET-HANDLE(ENTRY(1,link-handle)).
  IF NUM-ENTRIES(link-handle) > 1 THEN
      MESSAGE "row-available in ":U THIS-PROCEDURE:FILE-NAME
          "encountered more than one RECORD-SOURCE.":U SKIP
          "The first - ":U record-source-hdl:file-name " - will be used.":U
             VIEW-AS ALERT-BOX ERROR.
  RUN get-attribute ('Key-Name':U).
  key-name = RETURN-VALUE.
  IF key-name = "":U THEN key-name = ?.
  IF key-name NE ? THEN DO:
    RUN send-key IN record-source-hdl (INPUT key-name, OUTPUT key-value)
      NO-ERROR.
    IF key-value NE ? THEN
      RUN set-attribute-list (SUBSTITUTE ('Key-Value="&1"':U, key-value)).
  END.
IF VALID-HANDLE (adm-object-hdl) THEN
    RUN dispatch IN THIS-PROCEDURE ('display-fields':U).
  IF key-name ne ? OR different-row
  THEN RUN dispatch IN THIS-PROCEDURE ('open-query':U).
  ELSE RUN notify IN THIS-PROCEDURE('row-available':U).
END PROCEDURE.
PROCEDURE calc-field-frame :
  define variable varqnty-is-calc-start as logical   no-undo initial no .
  define variable varqnty-is-calc-end   as logical   no-undo initial no .
  define variable g-cost-arc            as logical   no-undo .
  define variable varcost               as character no-undo .
  define variable varcsdt               as character no-undo .
  define variable varcrsa               as character no-undo .
  define variable varcgdt               as character no-undo .
  define variable varsadt               as character no-undo .
  for each acc-stk-line
  :
    delete acc-stk-line.
  end.
  for each tt-kind-sum
  :
    delete tt-kind-sum.
  end.
  assign
    varqnty-start = 0
    varqnty-end   = 0
  .
  define variable v-chk-act-host-code as integer   no-undo .
  assign
    g-cost-arc = true
  .
  scan_block:
  for each tt-clients
  on error undo, return error return-value
  :
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  tt-clients.obj-type
  ,input  tt-clients.obj-code
  ,output v-chk-act-host-code
  )  .
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  tt-clients.obj-type
    ,input  tt-clients.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g-cost-arc
    )  .
end.
    if g-cost-arc <> true
    then do:
      leave scan_block.
    end.
  end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign fact-order-min = 0
       fact-order-max = 0.
for each tt-clients:
   run dfactord (input  tt-clients.obj-type,
                 input  tt-clients.obj-code,
                 input  (if varis-calend = 1 then yes else no),
                 input  varis-shift-num,
                 input  vardate-start,
                 input  vardate-end,
                 input  varshift-start,
                 input  varshift-end,
                 output fact-order-start,
                 output fact-order-end) no-error.
   if error-status:error then do:
      message "Ошибка при определении диапазона данных."
      view-as alert-box error.
      return no-apply.
   end.
   if fact-order-end = 0 then next.
   if fact-order-start > fact-order-min then assign fact-order-min = fact-order-start.
   if fact-order-end   > fact-order-max then assign fact-order-max = fact-order-end.
  define variable v-ind as integer   no-undo .
  define variable v-r-b-base as logical   no-undo .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-r-b-base
  )  .
  for each tt-goods
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Обработано товаров &1. Артикул &2", v-ind, tt-goods.artic)
        ) .
    end.
    assign
      varqnty-is-calc-start = no
      varqnty-is-calc-end   = no
    .
    assign
      varcost = (if tt-goods.gds-type = 'у':U then 'cssr':U else 'cost':U)
      varcsdt = (if tt-goods.gds-type = 'у':U then 'sdsr':U else 'csdt':U)
      varcrsa = (if tt-goods.gds-type = 'у':U then 'cgsr':U else 'crsa':U)
      varcgdt = (if tt-goods.gds-type = 'у':U then 'gdsr':U else 'cgdt':U)
      varsadt = (if tt-goods.gds-type = 'у':U then 'adsr':U else 'sadt':U)
    .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
for each tt-stk-line :
    delete tt-stk-line .
end.
run stk-lnst(input  tt-clients.obj-type,
             input  tt-clients.obj-code,
             input  tt-goods.artic,
             input  tt-goods.prod-type,
             input  tt-goods.prod-code,
             input  fact-order-start,
             input  varcost,
             input  '##,##':U,
             input  varis-shift-num,
             output table tt-stk-line ).
find first tt-stk-line  no-lock no-error.
if not varqnty-is-calc-start then do:
   assign varqnty-start = varqnty-start + (if available tt-stk-line  then tt-stk-line .fact-qnty else 0).
   assign varqnty-is-calc-start = yes.
end.
find first tt-kind-sum where tt-kind-sum.sum-kind = "Сумма" no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = "Сумма"                   tt-kind-sum.order    = 1.       end.       CASE varcost :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-start-base = tt-kind-sum.sum-start-base + (if available tt-stk-line  then tt-stk-line .sum-base else 0)            tt-kind-sum.sum-start-rubl = tt-kind-sum.sum-start-rubl + (if available tt-stk-line  then tt-stk-line .sum-rubl else 0).            else            assign            tt-kind-sum.sum-start-base = ?            tt-kind-sum.sum-start-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-start-rubl-sale = ?                    tt-kind-sum.sum-start-base-sale = tt-kind-sum.sum-start-base-sale + (if available tt-stk-line  then tt-stk-line .sum-base else 0).           end.           else do:             assign tt-kind-sum.sum-start-rubl-sale = tt-kind-sum.sum-start-rubl-sale + (if available tt-stk-line  then tt-stk-line .sum-rubl else 0).                    tt-kind-sum.sum-start-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcost " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
find first tt-kind-sum where tt-kind-sum.sum-kind = "НДС" no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = "НДС"                   tt-kind-sum.order    = 2.       end.       CASE varcost :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-start-base = tt-kind-sum.sum-start-base + (if available tt-stk-line  then tt-stk-line .vat-base else 0)            tt-kind-sum.sum-start-rubl = tt-kind-sum.sum-start-rubl + (if available tt-stk-line  then tt-stk-line .vat-rubl else 0).            else            assign            tt-kind-sum.sum-start-base = ?            tt-kind-sum.sum-start-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-start-rubl-sale = ?                    tt-kind-sum.sum-start-base-sale = tt-kind-sum.sum-start-base-sale + (if available tt-stk-line  then tt-stk-line .vat-base else 0).           end.           else do:             assign tt-kind-sum.sum-start-rubl-sale = tt-kind-sum.sum-start-rubl-sale + (if available tt-stk-line  then tt-stk-line .vat-rubl else 0).                    tt-kind-sum.sum-start-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcost " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
find first tt-kind-sum where tt-kind-sum.sum-kind = "НП" no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = "НП"                   tt-kind-sum.order    = 3.       end.       CASE varcost :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-start-base = tt-kind-sum.sum-start-base + (if available tt-stk-line  then tt-stk-line .slt-base else 0)            tt-kind-sum.sum-start-rubl = tt-kind-sum.sum-start-rubl + (if available tt-stk-line  then tt-stk-line .slt-rubl else 0).            else            assign            tt-kind-sum.sum-start-base = ?            tt-kind-sum.sum-start-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-start-rubl-sale = ?                    tt-kind-sum.sum-start-base-sale = tt-kind-sum.sum-start-base-sale + (if available tt-stk-line  then tt-stk-line .slt-base else 0).           end.           else do:             assign tt-kind-sum.sum-start-rubl-sale = tt-kind-sum.sum-start-rubl-sale + (if available tt-stk-line  then tt-stk-line .slt-rubl else 0).                    tt-kind-sum.sum-start-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcost " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
find first tt-kind-sum where tt-kind-sum.sum-kind = rdtaxname no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = rdtaxname                   tt-kind-sum.order    = 4.       end.       CASE varcost :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-start-base = tt-kind-sum.sum-start-base + (if available tt-stk-line  then tt-stk-line .road-tax-base else 0)            tt-kind-sum.sum-start-rubl = tt-kind-sum.sum-start-rubl + (if available tt-stk-line  then tt-stk-line .road-tax-rubl else 0).            else            assign            tt-kind-sum.sum-start-base = ?            tt-kind-sum.sum-start-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-start-rubl-sale = ?                    tt-kind-sum.sum-start-base-sale = tt-kind-sum.sum-start-base-sale + (if available tt-stk-line  then tt-stk-line .road-tax-base else 0).           end.           else do:             assign tt-kind-sum.sum-start-rubl-sale = tt-kind-sum.sum-start-rubl-sale + (if available tt-stk-line  then tt-stk-line .road-tax-rubl else 0).                    tt-kind-sum.sum-start-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcost " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
find first tt-kind-sum where tt-kind-sum.sum-kind = "Акциз" no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = "Акциз"                   tt-kind-sum.order    = 5.       end.       CASE varcost :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-start-base = tt-kind-sum.sum-start-base + (if available tt-stk-line  then tt-stk-line .excise-base else 0)            tt-kind-sum.sum-start-rubl = tt-kind-sum.sum-start-rubl + (if available tt-stk-line  then tt-stk-line .excise-rubl else 0).            else            assign            tt-kind-sum.sum-start-base = ?            tt-kind-sum.sum-start-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-start-rubl-sale = ?                    tt-kind-sum.sum-start-base-sale = tt-kind-sum.sum-start-base-sale + (if available tt-stk-line  then tt-stk-line .excise-base else 0).           end.           else do:             assign tt-kind-sum.sum-start-rubl-sale = tt-kind-sum.sum-start-rubl-sale + (if available tt-stk-line  then tt-stk-line .excise-rubl else 0).                    tt-kind-sum.sum-start-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcost " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
find first tt-kind-sum where tt-kind-sum.sum-kind = "Трансп.расходы" no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = "Трансп.расходы"                   tt-kind-sum.order    = 6.       end.       CASE varcost :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-start-base = tt-kind-sum.sum-start-base + (if available tt-stk-line  then tt-stk-line .transport-base else 0)            tt-kind-sum.sum-start-rubl = tt-kind-sum.sum-start-rubl + (if available tt-stk-line  then tt-stk-line .transport-rubl else 0).            else            assign            tt-kind-sum.sum-start-base = ?            tt-kind-sum.sum-start-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-start-rubl-sale = ?                    tt-kind-sum.sum-start-base-sale = tt-kind-sum.sum-start-base-sale + (if available tt-stk-line  then tt-stk-line .transport-base else 0).           end.           else do:             assign tt-kind-sum.sum-start-rubl-sale = tt-kind-sum.sum-start-rubl-sale + (if available tt-stk-line  then tt-stk-line .transport-rubl else 0).                    tt-kind-sum.sum-start-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcost " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
find first tt-kind-sum where tt-kind-sum.sum-kind = "Прочие расходы" no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = "Прочие расходы"                   tt-kind-sum.order    = 7.       end.       CASE varcost :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-start-base = tt-kind-sum.sum-start-base + (if available tt-stk-line  then tt-stk-line .other-base else 0)            tt-kind-sum.sum-start-rubl = tt-kind-sum.sum-start-rubl + (if available tt-stk-line  then tt-stk-line .other-rubl else 0).            else            assign            tt-kind-sum.sum-start-base = ?            tt-kind-sum.sum-start-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-start-rubl-sale = ?                    tt-kind-sum.sum-start-base-sale = tt-kind-sum.sum-start-base-sale + (if available tt-stk-line  then tt-stk-line .other-base else 0).           end.           else do:             assign tt-kind-sum.sum-start-rubl-sale = tt-kind-sum.sum-start-rubl-sale + (if available tt-stk-line  then tt-stk-line .other-rubl else 0).                    tt-kind-sum.sum-start-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcost " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
for each tt-stk-line :
    delete tt-stk-line .
end.
run stk-lnst(input  tt-clients.obj-type,
             input  tt-clients.obj-code,
             input  tt-goods.artic,
             input  tt-goods.prod-type,
             input  tt-goods.prod-code,
             input  fact-order-end,
             input  varcost,
             input  '##,##':U,
             input  varis-shift-num,
             output table tt-stk-line ).
find first tt-stk-line  no-lock no-error.
if not varqnty-is-calc-end then do:
   assign varqnty-end = varqnty-end + (if available tt-stk-line  then tt-stk-line .fact-qnty else 0).
   assign varqnty-is-calc-end = yes.
end.
find first tt-kind-sum where tt-kind-sum.sum-kind = "Сумма" no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = "Сумма"                   tt-kind-sum.order    = 1.       end.       CASE varcost :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-end-base = tt-kind-sum.sum-end-base + (if available tt-stk-line  then tt-stk-line .sum-base else 0)            tt-kind-sum.sum-end-rubl = tt-kind-sum.sum-end-rubl + (if available tt-stk-line  then tt-stk-line .sum-rubl else 0).            else            assign            tt-kind-sum.sum-end-base = ?            tt-kind-sum.sum-end-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-end-rubl-sale = ?                    tt-kind-sum.sum-end-base-sale = tt-kind-sum.sum-end-base-sale + (if available tt-stk-line  then tt-stk-line .sum-base else 0).           end.           else do:             assign tt-kind-sum.sum-end-rubl-sale = tt-kind-sum.sum-end-rubl-sale + (if available tt-stk-line  then tt-stk-line .sum-rubl else 0).                    tt-kind-sum.sum-end-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcost " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
find first tt-kind-sum where tt-kind-sum.sum-kind = "НДС" no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = "НДС"                   tt-kind-sum.order    = 2.       end.       CASE varcost :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-end-base = tt-kind-sum.sum-end-base + (if available tt-stk-line  then tt-stk-line .vat-base else 0)            tt-kind-sum.sum-end-rubl = tt-kind-sum.sum-end-rubl + (if available tt-stk-line  then tt-stk-line .vat-rubl else 0).            else            assign            tt-kind-sum.sum-end-base = ?            tt-kind-sum.sum-end-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-end-rubl-sale = ?                    tt-kind-sum.sum-end-base-sale = tt-kind-sum.sum-end-base-sale + (if available tt-stk-line  then tt-stk-line .vat-base else 0).           end.           else do:             assign tt-kind-sum.sum-end-rubl-sale = tt-kind-sum.sum-end-rubl-sale + (if available tt-stk-line  then tt-stk-line .vat-rubl else 0).                    tt-kind-sum.sum-end-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcost " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
find first tt-kind-sum where tt-kind-sum.sum-kind = "НП" no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = "НП"                   tt-kind-sum.order    = 3.       end.       CASE varcost :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-end-base = tt-kind-sum.sum-end-base + (if available tt-stk-line  then tt-stk-line .slt-base else 0)            tt-kind-sum.sum-end-rubl = tt-kind-sum.sum-end-rubl + (if available tt-stk-line  then tt-stk-line .slt-rubl else 0).            else            assign            tt-kind-sum.sum-end-base = ?            tt-kind-sum.sum-end-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-end-rubl-sale = ?                    tt-kind-sum.sum-end-base-sale = tt-kind-sum.sum-end-base-sale + (if available tt-stk-line  then tt-stk-line .slt-base else 0).           end.           else do:             assign tt-kind-sum.sum-end-rubl-sale = tt-kind-sum.sum-end-rubl-sale + (if available tt-stk-line  then tt-stk-line .slt-rubl else 0).                    tt-kind-sum.sum-end-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcost " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
find first tt-kind-sum where tt-kind-sum.sum-kind = rdtaxname no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = rdtaxname                   tt-kind-sum.order    = 4.       end.       CASE varcost :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-end-base = tt-kind-sum.sum-end-base + (if available tt-stk-line  then tt-stk-line .road-tax-base else 0)            tt-kind-sum.sum-end-rubl = tt-kind-sum.sum-end-rubl + (if available tt-stk-line  then tt-stk-line .road-tax-rubl else 0).            else            assign            tt-kind-sum.sum-end-base = ?            tt-kind-sum.sum-end-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-end-rubl-sale = ?                    tt-kind-sum.sum-end-base-sale = tt-kind-sum.sum-end-base-sale + (if available tt-stk-line  then tt-stk-line .road-tax-base else 0).           end.           else do:             assign tt-kind-sum.sum-end-rubl-sale = tt-kind-sum.sum-end-rubl-sale + (if available tt-stk-line  then tt-stk-line .road-tax-rubl else 0).                    tt-kind-sum.sum-end-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcost " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
find first tt-kind-sum where tt-kind-sum.sum-kind = "Акциз" no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = "Акциз"                   tt-kind-sum.order    = 5.       end.       CASE varcost :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-end-base = tt-kind-sum.sum-end-base + (if available tt-stk-line  then tt-stk-line .excise-base else 0)            tt-kind-sum.sum-end-rubl = tt-kind-sum.sum-end-rubl + (if available tt-stk-line  then tt-stk-line .excise-rubl else 0).            else            assign            tt-kind-sum.sum-end-base = ?            tt-kind-sum.sum-end-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-end-rubl-sale = ?                    tt-kind-sum.sum-end-base-sale = tt-kind-sum.sum-end-base-sale + (if available tt-stk-line  then tt-stk-line .excise-base else 0).           end.           else do:             assign tt-kind-sum.sum-end-rubl-sale = tt-kind-sum.sum-end-rubl-sale + (if available tt-stk-line  then tt-stk-line .excise-rubl else 0).                    tt-kind-sum.sum-end-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcost " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
find first tt-kind-sum where tt-kind-sum.sum-kind = "Трансп.расходы" no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = "Трансп.расходы"                   tt-kind-sum.order    = 6.       end.       CASE varcost :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-end-base = tt-kind-sum.sum-end-base + (if available tt-stk-line  then tt-stk-line .transport-base else 0)            tt-kind-sum.sum-end-rubl = tt-kind-sum.sum-end-rubl + (if available tt-stk-line  then tt-stk-line .transport-rubl else 0).            else            assign            tt-kind-sum.sum-end-base = ?            tt-kind-sum.sum-end-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-end-rubl-sale = ?                    tt-kind-sum.sum-end-base-sale = tt-kind-sum.sum-end-base-sale + (if available tt-stk-line  then tt-stk-line .transport-base else 0).           end.           else do:             assign tt-kind-sum.sum-end-rubl-sale = tt-kind-sum.sum-end-rubl-sale + (if available tt-stk-line  then tt-stk-line .transport-rubl else 0).                    tt-kind-sum.sum-end-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcost " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
find first tt-kind-sum where tt-kind-sum.sum-kind = "Прочие расходы" no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = "Прочие расходы"                   tt-kind-sum.order    = 7.       end.       CASE varcost :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-end-base = tt-kind-sum.sum-end-base + (if available tt-stk-line  then tt-stk-line .other-base else 0)            tt-kind-sum.sum-end-rubl = tt-kind-sum.sum-end-rubl + (if available tt-stk-line  then tt-stk-line .other-rubl else 0).            else            assign            tt-kind-sum.sum-end-base = ?            tt-kind-sum.sum-end-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-end-rubl-sale = ?                    tt-kind-sum.sum-end-base-sale = tt-kind-sum.sum-end-base-sale + (if available tt-stk-line  then tt-stk-line .other-base else 0).           end.           else do:             assign tt-kind-sum.sum-end-rubl-sale = tt-kind-sum.sum-end-rubl-sale + (if available tt-stk-line  then tt-stk-line .other-rubl else 0).                    tt-kind-sum.sum-end-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcost " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
for each tt-stk-line:
    delete tt-stk-line.
end.
run stk-lnrv(
    input  tt-clients.obj-type,
    input  tt-clients.obj-code,
    input  tt-goods.artic,
    input  tt-goods.prod-type,
    input  tt-goods.prod-code,
    input  fact-order-start,
    input  fact-order-end,
    input  varcsdt,
    input  '##,##':U,
    input  varis-shift-num,
    output table tt-stk-line).
for each tt-stk-line:
    assign varorder = lookup(substring(tt-stk-line.sum-type, length(varcsdt) + 1), 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U).
    find first acc-stk-line where acc-stk-line.order = varorder no-error.
    if not available acc-stk-line then do:
       create acc-stk-line.
       assign
       acc-stk-line.obj-type          = ?
       acc-stk-line.obj-code          = ?
       acc-stk-line.artic             = ?
       acc-stk-line.prod-type         = ?
       acc-stk-line.prod-code         = ?
       acc-stk-line.sum-type          = ?
       acc-stk-line.cat-id            = '##,##':U
       acc-stk-line.order             = varorder
       acc-stk-line.ext-doc-type      = substring(tt-stk-line.sum-type, length(varcsdt) + 1)
       acc-stk-line.ext-doc-type-full = entry(acc-stk-line.order, 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U).
    end.
    CASE varcsdt:
       WHEN 'csdt':U or
       WHEN 'sdsr':U then do:
          assign acc-stk-line.fact-qnty = acc-stk-line.fact-qnty + tt-stk-line.fact-qnty.
          if g-cost-arc then
          assign
          acc-stk-line.sum-base       = acc-stk-line.sum-base       + tt-stk-line.sum-base
          acc-stk-line.sum-rubl       = acc-stk-line.sum-rubl       + tt-stk-line.sum-rubl
          acc-stk-line.vat-base       = acc-stk-line.vat-base       + tt-stk-line.vat-base
          acc-stk-line.vat-rubl       = acc-stk-line.vat-rubl       + tt-stk-line.vat-rubl
          acc-stk-line.slt-base       = acc-stk-line.slt-base       + tt-stk-line.slt-base
          acc-stk-line.slt-rubl       = acc-stk-line.slt-rubl       + tt-stk-line.slt-rubl
          acc-stk-line.road-tax-base  = acc-stk-line.road-tax-base  + tt-stk-line.road-tax-base
          acc-stk-line.road-tax-rubl  = acc-stk-line.road-tax-rubl  + tt-stk-line.road-tax-rubl
          acc-stk-line.excise-base    = acc-stk-line.excise-base    + tt-stk-line.excise-base
          acc-stk-line.excise-rubl    = acc-stk-line.excise-rubl    + tt-stk-line.excise-rubl
          acc-stk-line.transport-base = acc-stk-line.transport-base + tt-stk-line.transport-base
          acc-stk-line.transport-rubl = acc-stk-line.transport-rubl + tt-stk-line.transport-rubl
          acc-stk-line.other-base     = acc-stk-line.other-base     + tt-stk-line.other-base
          acc-stk-line.other-rubl     = acc-stk-line.other-rubl     + tt-stk-line.other-rubl.
          else
          assign
          acc-stk-line.sum-base       = ?
          acc-stk-line.sum-rubl       = ?
          acc-stk-line.vat-base       = ?
          acc-stk-line.vat-rubl       = ?
          acc-stk-line.slt-base       = ?
          acc-stk-line.slt-rubl       = ?
          acc-stk-line.road-tax-base  = ?
          acc-stk-line.road-tax-rubl  = ?
          acc-stk-line.excise-base    = ?
          acc-stk-line.excise-rubl    = ?
          acc-stk-line.transport-base = ?
          acc-stk-line.transport-rubl = ?
          acc-stk-line.other-base     = ?
          acc-stk-line.other-rubl     = ?.
       end.
       WHEN 'cgdt':U or
       WHEN 'gdsr':U THEN
       assign
       acc-stk-line.sum-base-sale       = acc-stk-line.sum-base-sale       + tt-stk-line.sum-base
       acc-stk-line.sum-rubl-sale       = acc-stk-line.sum-rubl-sale       + tt-stk-line.sum-rubl
       acc-stk-line.vat-base-sale       = acc-stk-line.vat-base-sale       + tt-stk-line.vat-base
       acc-stk-line.vat-rubl-sale       = acc-stk-line.vat-rubl-sale       + tt-stk-line.vat-rubl
       acc-stk-line.slt-base-sale       = acc-stk-line.slt-base-sale       + tt-stk-line.slt-base
       acc-stk-line.slt-rubl-sale       = acc-stk-line.slt-rubl-sale       + tt-stk-line.slt-rubl
       acc-stk-line.road-tax-base-sale  = acc-stk-line.road-tax-base-sale  + tt-stk-line.road-tax-base
       acc-stk-line.road-tax-rubl-sale  = acc-stk-line.road-tax-rubl-sale  + tt-stk-line.road-tax-rubl
       acc-stk-line.excise-base-sale    = acc-stk-line.excise-base-sale    + tt-stk-line.excise-base
       acc-stk-line.excise-rubl-sale    = acc-stk-line.excise-rubl-sale    + tt-stk-line.excise-rubl
       acc-stk-line.transport-base-sale = acc-stk-line.transport-base-sale + tt-stk-line.transport-base
       acc-stk-line.transport-rubl-sale = acc-stk-line.transport-rubl-sale + tt-stk-line.transport-rubl
       acc-stk-line.other-base-sale     = acc-stk-line.other-base-sale     + tt-stk-line.other-base
       acc-stk-line.other-rubl-sale     = acc-stk-line.other-rubl-sale     + tt-stk-line.other-rubl.
       WHEN 'sadt':U or
       WHEN 'adsr':U THEN
       assign
       acc-stk-line.sum-base-doc       = acc-stk-line.sum-base-doc       + tt-stk-line.sum-base
       acc-stk-line.sum-rubl-doc       = acc-stk-line.sum-rubl-doc       + tt-stk-line.sum-rubl
       acc-stk-line.vat-base-doc       = acc-stk-line.vat-base-doc       + tt-stk-line.vat-base
       acc-stk-line.vat-rubl-doc       = acc-stk-line.vat-rubl-doc       + tt-stk-line.vat-rubl
       acc-stk-line.slt-base-doc       = acc-stk-line.slt-base-doc       + tt-stk-line.slt-base
       acc-stk-line.slt-rubl-doc       = acc-stk-line.slt-rubl-doc       + tt-stk-line.slt-rubl
       acc-stk-line.road-tax-base-doc  = acc-stk-line.road-tax-base-doc  + tt-stk-line.road-tax-base
       acc-stk-line.road-tax-rubl-doc  = acc-stk-line.road-tax-rubl-doc  + tt-stk-line.road-tax-rubl
       acc-stk-line.excise-base-doc    = acc-stk-line.excise-base-doc    + tt-stk-line.excise-base
       acc-stk-line.excise-rubl-doc    = acc-stk-line.excise-rubl-doc    + tt-stk-line.excise-rubl
       acc-stk-line.transport-base-doc = acc-stk-line.transport-base-doc + tt-stk-line.transport-base
       acc-stk-line.transport-rubl-doc = acc-stk-line.transport-rubl-doc + tt-stk-line.transport-rubl
       acc-stk-line.other-base-doc     = acc-stk-line.other-base-doc     + tt-stk-line.other-base
       acc-stk-line.other-rubl-doc     = acc-stk-line.other-rubl-doc     + tt-stk-line.other-rubl.
       otherwise do:
          message "Некорректный sum-type " varcsdt " при просмотре архива(main-arr.i)." skip
                  "Ошибка в расчетах."
          view-as alert-box error.
       end.
    END CASE.
end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
for each tt-stk-line :
    delete tt-stk-line .
end.
run stk-lnst(input  tt-clients.obj-type,
             input  tt-clients.obj-code,
             input  tt-goods.artic,
             input  tt-goods.prod-type,
             input  tt-goods.prod-code,
             input  fact-order-start,
             input  varcrsa,
             input  '##,##':U,
             input  varis-shift-num,
             output table tt-stk-line ).
find first tt-stk-line  no-lock no-error.
if not varqnty-is-calc-start then do:
   assign varqnty-start = varqnty-start + (if available tt-stk-line  then tt-stk-line .fact-qnty else 0).
   assign varqnty-is-calc-start = yes.
end.
find first tt-kind-sum where tt-kind-sum.sum-kind = "Сумма" no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = "Сумма"                   tt-kind-sum.order    = 1.       end.       CASE varcrsa :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-start-base = tt-kind-sum.sum-start-base + (if available tt-stk-line  then tt-stk-line .sum-base else 0)            tt-kind-sum.sum-start-rubl = tt-kind-sum.sum-start-rubl + (if available tt-stk-line  then tt-stk-line .sum-rubl else 0).            else            assign            tt-kind-sum.sum-start-base = ?            tt-kind-sum.sum-start-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-start-rubl-sale = ?                    tt-kind-sum.sum-start-base-sale = tt-kind-sum.sum-start-base-sale + (if available tt-stk-line  then tt-stk-line .sum-base else 0).           end.           else do:             assign tt-kind-sum.sum-start-rubl-sale = tt-kind-sum.sum-start-rubl-sale + (if available tt-stk-line  then tt-stk-line .sum-rubl else 0).                    tt-kind-sum.sum-start-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcrsa " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
find first tt-kind-sum where tt-kind-sum.sum-kind = "НДС" no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = "НДС"                   tt-kind-sum.order    = 2.       end.       CASE varcrsa :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-start-base = tt-kind-sum.sum-start-base + (if available tt-stk-line  then tt-stk-line .vat-base else 0)            tt-kind-sum.sum-start-rubl = tt-kind-sum.sum-start-rubl + (if available tt-stk-line  then tt-stk-line .vat-rubl else 0).            else            assign            tt-kind-sum.sum-start-base = ?            tt-kind-sum.sum-start-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-start-rubl-sale = ?                    tt-kind-sum.sum-start-base-sale = tt-kind-sum.sum-start-base-sale + (if available tt-stk-line  then tt-stk-line .vat-base else 0).           end.           else do:             assign tt-kind-sum.sum-start-rubl-sale = tt-kind-sum.sum-start-rubl-sale + (if available tt-stk-line  then tt-stk-line .vat-rubl else 0).                    tt-kind-sum.sum-start-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcrsa " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
find first tt-kind-sum where tt-kind-sum.sum-kind = "НП" no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = "НП"                   tt-kind-sum.order    = 3.       end.       CASE varcrsa :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-start-base = tt-kind-sum.sum-start-base + (if available tt-stk-line  then tt-stk-line .slt-base else 0)            tt-kind-sum.sum-start-rubl = tt-kind-sum.sum-start-rubl + (if available tt-stk-line  then tt-stk-line .slt-rubl else 0).            else            assign            tt-kind-sum.sum-start-base = ?            tt-kind-sum.sum-start-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-start-rubl-sale = ?                    tt-kind-sum.sum-start-base-sale = tt-kind-sum.sum-start-base-sale + (if available tt-stk-line  then tt-stk-line .slt-base else 0).           end.           else do:             assign tt-kind-sum.sum-start-rubl-sale = tt-kind-sum.sum-start-rubl-sale + (if available tt-stk-line  then tt-stk-line .slt-rubl else 0).                    tt-kind-sum.sum-start-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcrsa " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
find first tt-kind-sum where tt-kind-sum.sum-kind = rdtaxname no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = rdtaxname                   tt-kind-sum.order    = 4.       end.       CASE varcrsa :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-start-base = tt-kind-sum.sum-start-base + (if available tt-stk-line  then tt-stk-line .road-tax-base else 0)            tt-kind-sum.sum-start-rubl = tt-kind-sum.sum-start-rubl + (if available tt-stk-line  then tt-stk-line .road-tax-rubl else 0).            else            assign            tt-kind-sum.sum-start-base = ?            tt-kind-sum.sum-start-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-start-rubl-sale = ?                    tt-kind-sum.sum-start-base-sale = tt-kind-sum.sum-start-base-sale + (if available tt-stk-line  then tt-stk-line .road-tax-base else 0).           end.           else do:             assign tt-kind-sum.sum-start-rubl-sale = tt-kind-sum.sum-start-rubl-sale + (if available tt-stk-line  then tt-stk-line .road-tax-rubl else 0).                    tt-kind-sum.sum-start-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcrsa " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
find first tt-kind-sum where tt-kind-sum.sum-kind = "Акциз" no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = "Акциз"                   tt-kind-sum.order    = 5.       end.       CASE varcrsa :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-start-base = tt-kind-sum.sum-start-base + (if available tt-stk-line  then tt-stk-line .excise-base else 0)            tt-kind-sum.sum-start-rubl = tt-kind-sum.sum-start-rubl + (if available tt-stk-line  then tt-stk-line .excise-rubl else 0).            else            assign            tt-kind-sum.sum-start-base = ?            tt-kind-sum.sum-start-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-start-rubl-sale = ?                    tt-kind-sum.sum-start-base-sale = tt-kind-sum.sum-start-base-sale + (if available tt-stk-line  then tt-stk-line .excise-base else 0).           end.           else do:             assign tt-kind-sum.sum-start-rubl-sale = tt-kind-sum.sum-start-rubl-sale + (if available tt-stk-line  then tt-stk-line .excise-rubl else 0).                    tt-kind-sum.sum-start-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcrsa " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
find first tt-kind-sum where tt-kind-sum.sum-kind = "Трансп.расходы" no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = "Трансп.расходы"                   tt-kind-sum.order    = 6.       end.       CASE varcrsa :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-start-base = tt-kind-sum.sum-start-base + (if available tt-stk-line  then tt-stk-line .transport-base else 0)            tt-kind-sum.sum-start-rubl = tt-kind-sum.sum-start-rubl + (if available tt-stk-line  then tt-stk-line .transport-rubl else 0).            else            assign            tt-kind-sum.sum-start-base = ?            tt-kind-sum.sum-start-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-start-rubl-sale = ?                    tt-kind-sum.sum-start-base-sale = tt-kind-sum.sum-start-base-sale + (if available tt-stk-line  then tt-stk-line .transport-base else 0).           end.           else do:             assign tt-kind-sum.sum-start-rubl-sale = tt-kind-sum.sum-start-rubl-sale + (if available tt-stk-line  then tt-stk-line .transport-rubl else 0).                    tt-kind-sum.sum-start-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcrsa " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
find first tt-kind-sum where tt-kind-sum.sum-kind = "Прочие расходы" no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = "Прочие расходы"                   tt-kind-sum.order    = 7.       end.       CASE varcrsa :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-start-base = tt-kind-sum.sum-start-base + (if available tt-stk-line  then tt-stk-line .other-base else 0)            tt-kind-sum.sum-start-rubl = tt-kind-sum.sum-start-rubl + (if available tt-stk-line  then tt-stk-line .other-rubl else 0).            else            assign            tt-kind-sum.sum-start-base = ?            tt-kind-sum.sum-start-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-start-rubl-sale = ?                    tt-kind-sum.sum-start-base-sale = tt-kind-sum.sum-start-base-sale + (if available tt-stk-line  then tt-stk-line .other-base else 0).           end.           else do:             assign tt-kind-sum.sum-start-rubl-sale = tt-kind-sum.sum-start-rubl-sale + (if available tt-stk-line  then tt-stk-line .other-rubl else 0).                    tt-kind-sum.sum-start-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcrsa " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
for each tt-stk-line :
    delete tt-stk-line .
end.
run stk-lnst(input  tt-clients.obj-type,
             input  tt-clients.obj-code,
             input  tt-goods.artic,
             input  tt-goods.prod-type,
             input  tt-goods.prod-code,
             input  fact-order-end,
             input  varcrsa,
             input  '##,##':U,
             input  varis-shift-num,
             output table tt-stk-line ).
find first tt-stk-line  no-lock no-error.
if not varqnty-is-calc-end then do:
   assign varqnty-end = varqnty-end + (if available tt-stk-line  then tt-stk-line .fact-qnty else 0).
   assign varqnty-is-calc-end = yes.
end.
find first tt-kind-sum where tt-kind-sum.sum-kind = "Сумма" no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = "Сумма"                   tt-kind-sum.order    = 1.       end.       CASE varcrsa :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-end-base = tt-kind-sum.sum-end-base + (if available tt-stk-line  then tt-stk-line .sum-base else 0)            tt-kind-sum.sum-end-rubl = tt-kind-sum.sum-end-rubl + (if available tt-stk-line  then tt-stk-line .sum-rubl else 0).            else            assign            tt-kind-sum.sum-end-base = ?            tt-kind-sum.sum-end-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-end-rubl-sale = ?                    tt-kind-sum.sum-end-base-sale = tt-kind-sum.sum-end-base-sale + (if available tt-stk-line  then tt-stk-line .sum-base else 0).           end.           else do:             assign tt-kind-sum.sum-end-rubl-sale = tt-kind-sum.sum-end-rubl-sale + (if available tt-stk-line  then tt-stk-line .sum-rubl else 0).                    tt-kind-sum.sum-end-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcrsa " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
find first tt-kind-sum where tt-kind-sum.sum-kind = "НДС" no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = "НДС"                   tt-kind-sum.order    = 2.       end.       CASE varcrsa :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-end-base = tt-kind-sum.sum-end-base + (if available tt-stk-line  then tt-stk-line .vat-base else 0)            tt-kind-sum.sum-end-rubl = tt-kind-sum.sum-end-rubl + (if available tt-stk-line  then tt-stk-line .vat-rubl else 0).            else            assign            tt-kind-sum.sum-end-base = ?            tt-kind-sum.sum-end-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-end-rubl-sale = ?                    tt-kind-sum.sum-end-base-sale = tt-kind-sum.sum-end-base-sale + (if available tt-stk-line  then tt-stk-line .vat-base else 0).           end.           else do:             assign tt-kind-sum.sum-end-rubl-sale = tt-kind-sum.sum-end-rubl-sale + (if available tt-stk-line  then tt-stk-line .vat-rubl else 0).                    tt-kind-sum.sum-end-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcrsa " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
find first tt-kind-sum where tt-kind-sum.sum-kind = "НП" no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = "НП"                   tt-kind-sum.order    = 3.       end.       CASE varcrsa :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-end-base = tt-kind-sum.sum-end-base + (if available tt-stk-line  then tt-stk-line .slt-base else 0)            tt-kind-sum.sum-end-rubl = tt-kind-sum.sum-end-rubl + (if available tt-stk-line  then tt-stk-line .slt-rubl else 0).            else            assign            tt-kind-sum.sum-end-base = ?            tt-kind-sum.sum-end-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-end-rubl-sale = ?                    tt-kind-sum.sum-end-base-sale = tt-kind-sum.sum-end-base-sale + (if available tt-stk-line  then tt-stk-line .slt-base else 0).           end.           else do:             assign tt-kind-sum.sum-end-rubl-sale = tt-kind-sum.sum-end-rubl-sale + (if available tt-stk-line  then tt-stk-line .slt-rubl else 0).                    tt-kind-sum.sum-end-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcrsa " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
find first tt-kind-sum where tt-kind-sum.sum-kind = rdtaxname no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = rdtaxname                   tt-kind-sum.order    = 4.       end.       CASE varcrsa :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-end-base = tt-kind-sum.sum-end-base + (if available tt-stk-line  then tt-stk-line .road-tax-base else 0)            tt-kind-sum.sum-end-rubl = tt-kind-sum.sum-end-rubl + (if available tt-stk-line  then tt-stk-line .road-tax-rubl else 0).            else            assign            tt-kind-sum.sum-end-base = ?            tt-kind-sum.sum-end-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-end-rubl-sale = ?                    tt-kind-sum.sum-end-base-sale = tt-kind-sum.sum-end-base-sale + (if available tt-stk-line  then tt-stk-line .road-tax-base else 0).           end.           else do:             assign tt-kind-sum.sum-end-rubl-sale = tt-kind-sum.sum-end-rubl-sale + (if available tt-stk-line  then tt-stk-line .road-tax-rubl else 0).                    tt-kind-sum.sum-end-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcrsa " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
find first tt-kind-sum where tt-kind-sum.sum-kind = "Акциз" no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = "Акциз"                   tt-kind-sum.order    = 5.       end.       CASE varcrsa :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-end-base = tt-kind-sum.sum-end-base + (if available tt-stk-line  then tt-stk-line .excise-base else 0)            tt-kind-sum.sum-end-rubl = tt-kind-sum.sum-end-rubl + (if available tt-stk-line  then tt-stk-line .excise-rubl else 0).            else            assign            tt-kind-sum.sum-end-base = ?            tt-kind-sum.sum-end-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-end-rubl-sale = ?                    tt-kind-sum.sum-end-base-sale = tt-kind-sum.sum-end-base-sale + (if available tt-stk-line  then tt-stk-line .excise-base else 0).           end.           else do:             assign tt-kind-sum.sum-end-rubl-sale = tt-kind-sum.sum-end-rubl-sale + (if available tt-stk-line  then tt-stk-line .excise-rubl else 0).                    tt-kind-sum.sum-end-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcrsa " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
find first tt-kind-sum where tt-kind-sum.sum-kind = "Трансп.расходы" no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = "Трансп.расходы"                   tt-kind-sum.order    = 6.       end.       CASE varcrsa :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-end-base = tt-kind-sum.sum-end-base + (if available tt-stk-line  then tt-stk-line .transport-base else 0)            tt-kind-sum.sum-end-rubl = tt-kind-sum.sum-end-rubl + (if available tt-stk-line  then tt-stk-line .transport-rubl else 0).            else            assign            tt-kind-sum.sum-end-base = ?            tt-kind-sum.sum-end-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-end-rubl-sale = ?                    tt-kind-sum.sum-end-base-sale = tt-kind-sum.sum-end-base-sale + (if available tt-stk-line  then tt-stk-line .transport-base else 0).           end.           else do:             assign tt-kind-sum.sum-end-rubl-sale = tt-kind-sum.sum-end-rubl-sale + (if available tt-stk-line  then tt-stk-line .transport-rubl else 0).                    tt-kind-sum.sum-end-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcrsa " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
find first tt-kind-sum where tt-kind-sum.sum-kind = "Прочие расходы" no-error.       if not available tt-kind-sum  then do:           create tt-kind-sum.           assign tt-kind-sum.sum-kind = "Прочие расходы"                   tt-kind-sum.order    = 7.       end.       CASE varcrsa :       WHEN 'cost':U OR        WHEN 'cssr':U then do:            if g-cost-arc then            assign            tt-kind-sum.sum-end-base = tt-kind-sum.sum-end-base + (if available tt-stk-line  then tt-stk-line .other-base else 0)            tt-kind-sum.sum-end-rubl = tt-kind-sum.sum-end-rubl + (if available tt-stk-line  then tt-stk-line .other-rubl else 0).            else            assign            tt-kind-sum.sum-end-base = ?            tt-kind-sum.sum-end-rubl = ?.       end.       when 'crsa':U OR       when 'cgsr':U then do:           if v-r-b-base = true then do:             assign tt-kind-sum.sum-end-rubl-sale = ?                    tt-kind-sum.sum-end-base-sale = tt-kind-sum.sum-end-base-sale + (if available tt-stk-line  then tt-stk-line .other-base else 0).           end.           else do:             assign tt-kind-sum.sum-end-rubl-sale = tt-kind-sum.sum-end-rubl-sale + (if available tt-stk-line  then tt-stk-line .other-rubl else 0).                    tt-kind-sum.sum-end-base-sale = ?.           end.       end.       otherwise do:           message "Некорректный sum-type " varcrsa " при просмотре архива(main-arc.i)." skip                   "Ошибка в расчетах."           view-as alert-box error.       end.       end case.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
for each tt-stk-line:
    delete tt-stk-line.
end.
run stk-lnrv(
    input  tt-clients.obj-type,
    input  tt-clients.obj-code,
    input  tt-goods.artic,
    input  tt-goods.prod-type,
    input  tt-goods.prod-code,
    input  fact-order-start,
    input  fact-order-end,
    input  varcgdt,
    input  '##,##':U,
    input  varis-shift-num,
    output table tt-stk-line).
for each tt-stk-line:
    assign varorder = lookup(substring(tt-stk-line.sum-type, length(varcgdt) + 1), 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U).
    find first acc-stk-line where acc-stk-line.order = varorder no-error.
    if not available acc-stk-line then do:
       create acc-stk-line.
       assign
       acc-stk-line.obj-type          = ?
       acc-stk-line.obj-code          = ?
       acc-stk-line.artic             = ?
       acc-stk-line.prod-type         = ?
       acc-stk-line.prod-code         = ?
       acc-stk-line.sum-type          = ?
       acc-stk-line.cat-id            = '##,##':U
       acc-stk-line.order             = varorder
       acc-stk-line.ext-doc-type      = substring(tt-stk-line.sum-type, length(varcgdt) + 1)
       acc-stk-line.ext-doc-type-full = entry(acc-stk-line.order, 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U).
    end.
    CASE varcgdt:
       WHEN 'csdt':U or
       WHEN 'sdsr':U then do:
          assign acc-stk-line.fact-qnty = acc-stk-line.fact-qnty + tt-stk-line.fact-qnty.
          if g-cost-arc then
          assign
          acc-stk-line.sum-base       = acc-stk-line.sum-base       + tt-stk-line.sum-base
          acc-stk-line.sum-rubl       = acc-stk-line.sum-rubl       + tt-stk-line.sum-rubl
          acc-stk-line.vat-base       = acc-stk-line.vat-base       + tt-stk-line.vat-base
          acc-stk-line.vat-rubl       = acc-stk-line.vat-rubl       + tt-stk-line.vat-rubl
          acc-stk-line.slt-base       = acc-stk-line.slt-base       + tt-stk-line.slt-base
          acc-stk-line.slt-rubl       = acc-stk-line.slt-rubl       + tt-stk-line.slt-rubl
          acc-stk-line.road-tax-base  = acc-stk-line.road-tax-base  + tt-stk-line.road-tax-base
          acc-stk-line.road-tax-rubl  = acc-stk-line.road-tax-rubl  + tt-stk-line.road-tax-rubl
          acc-stk-line.excise-base    = acc-stk-line.excise-base    + tt-stk-line.excise-base
          acc-stk-line.excise-rubl    = acc-stk-line.excise-rubl    + tt-stk-line.excise-rubl
          acc-stk-line.transport-base = acc-stk-line.transport-base + tt-stk-line.transport-base
          acc-stk-line.transport-rubl = acc-stk-line.transport-rubl + tt-stk-line.transport-rubl
          acc-stk-line.other-base     = acc-stk-line.other-base     + tt-stk-line.other-base
          acc-stk-line.other-rubl     = acc-stk-line.other-rubl     + tt-stk-line.other-rubl.
          else
          assign
          acc-stk-line.sum-base       = ?
          acc-stk-line.sum-rubl       = ?
          acc-stk-line.vat-base       = ?
          acc-stk-line.vat-rubl       = ?
          acc-stk-line.slt-base       = ?
          acc-stk-line.slt-rubl       = ?
          acc-stk-line.road-tax-base  = ?
          acc-stk-line.road-tax-rubl  = ?
          acc-stk-line.excise-base    = ?
          acc-stk-line.excise-rubl    = ?
          acc-stk-line.transport-base = ?
          acc-stk-line.transport-rubl = ?
          acc-stk-line.other-base     = ?
          acc-stk-line.other-rubl     = ?.
       end.
       WHEN 'cgdt':U or
       WHEN 'gdsr':U THEN
       assign
       acc-stk-line.sum-base-sale       = acc-stk-line.sum-base-sale       + tt-stk-line.sum-base
       acc-stk-line.sum-rubl-sale       = acc-stk-line.sum-rubl-sale       + tt-stk-line.sum-rubl
       acc-stk-line.vat-base-sale       = acc-stk-line.vat-base-sale       + tt-stk-line.vat-base
       acc-stk-line.vat-rubl-sale       = acc-stk-line.vat-rubl-sale       + tt-stk-line.vat-rubl
       acc-stk-line.slt-base-sale       = acc-stk-line.slt-base-sale       + tt-stk-line.slt-base
       acc-stk-line.slt-rubl-sale       = acc-stk-line.slt-rubl-sale       + tt-stk-line.slt-rubl
       acc-stk-line.road-tax-base-sale  = acc-stk-line.road-tax-base-sale  + tt-stk-line.road-tax-base
       acc-stk-line.road-tax-rubl-sale  = acc-stk-line.road-tax-rubl-sale  + tt-stk-line.road-tax-rubl
       acc-stk-line.excise-base-sale    = acc-stk-line.excise-base-sale    + tt-stk-line.excise-base
       acc-stk-line.excise-rubl-sale    = acc-stk-line.excise-rubl-sale    + tt-stk-line.excise-rubl
       acc-stk-line.transport-base-sale = acc-stk-line.transport-base-sale + tt-stk-line.transport-base
       acc-stk-line.transport-rubl-sale = acc-stk-line.transport-rubl-sale + tt-stk-line.transport-rubl
       acc-stk-line.other-base-sale     = acc-stk-line.other-base-sale     + tt-stk-line.other-base
       acc-stk-line.other-rubl-sale     = acc-stk-line.other-rubl-sale     + tt-stk-line.other-rubl.
       WHEN 'sadt':U or
       WHEN 'adsr':U THEN
       assign
       acc-stk-line.sum-base-doc       = acc-stk-line.sum-base-doc       + tt-stk-line.sum-base
       acc-stk-line.sum-rubl-doc       = acc-stk-line.sum-rubl-doc       + tt-stk-line.sum-rubl
       acc-stk-line.vat-base-doc       = acc-stk-line.vat-base-doc       + tt-stk-line.vat-base
       acc-stk-line.vat-rubl-doc       = acc-stk-line.vat-rubl-doc       + tt-stk-line.vat-rubl
       acc-stk-line.slt-base-doc       = acc-stk-line.slt-base-doc       + tt-stk-line.slt-base
       acc-stk-line.slt-rubl-doc       = acc-stk-line.slt-rubl-doc       + tt-stk-line.slt-rubl
       acc-stk-line.road-tax-base-doc  = acc-stk-line.road-tax-base-doc  + tt-stk-line.road-tax-base
       acc-stk-line.road-tax-rubl-doc  = acc-stk-line.road-tax-rubl-doc  + tt-stk-line.road-tax-rubl
       acc-stk-line.excise-base-doc    = acc-stk-line.excise-base-doc    + tt-stk-line.excise-base
       acc-stk-line.excise-rubl-doc    = acc-stk-line.excise-rubl-doc    + tt-stk-line.excise-rubl
       acc-stk-line.transport-base-doc = acc-stk-line.transport-base-doc + tt-stk-line.transport-base
       acc-stk-line.transport-rubl-doc = acc-stk-line.transport-rubl-doc + tt-stk-line.transport-rubl
       acc-stk-line.other-base-doc     = acc-stk-line.other-base-doc     + tt-stk-line.other-base
       acc-stk-line.other-rubl-doc     = acc-stk-line.other-rubl-doc     + tt-stk-line.other-rubl.
       otherwise do:
          message "Некорректный sum-type " varcgdt " при просмотре архива(main-arr.i)." skip
                  "Ошибка в расчетах."
          view-as alert-box error.
       end.
    END CASE.
end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
for each tt-stk-line:
    delete tt-stk-line.
end.
run stk-lnrv(
    input  tt-clients.obj-type,
    input  tt-clients.obj-code,
    input  tt-goods.artic,
    input  tt-goods.prod-type,
    input  tt-goods.prod-code,
    input  fact-order-start,
    input  fact-order-end,
    input  varsadt,
    input  '##,##':U,
    input  varis-shift-num,
    output table tt-stk-line).
for each tt-stk-line:
    assign varorder = lookup(substring(tt-stk-line.sum-type, length(varsadt) + 1), 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U).
    find first acc-stk-line where acc-stk-line.order = varorder no-error.
    if not available acc-stk-line then do:
       create acc-stk-line.
       assign
       acc-stk-line.obj-type          = ?
       acc-stk-line.obj-code          = ?
       acc-stk-line.artic             = ?
       acc-stk-line.prod-type         = ?
       acc-stk-line.prod-code         = ?
       acc-stk-line.sum-type          = ?
       acc-stk-line.cat-id            = '##,##':U
       acc-stk-line.order             = varorder
       acc-stk-line.ext-doc-type      = substring(tt-stk-line.sum-type, length(varsadt) + 1)
       acc-stk-line.ext-doc-type-full = entry(acc-stk-line.order, 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U).
    end.
    CASE varsadt:
       WHEN 'csdt':U or
       WHEN 'sdsr':U then do:
          assign acc-stk-line.fact-qnty = acc-stk-line.fact-qnty + tt-stk-line.fact-qnty.
          if g-cost-arc then
          assign
          acc-stk-line.sum-base       = acc-stk-line.sum-base       + tt-stk-line.sum-base
          acc-stk-line.sum-rubl       = acc-stk-line.sum-rubl       + tt-stk-line.sum-rubl
          acc-stk-line.vat-base       = acc-stk-line.vat-base       + tt-stk-line.vat-base
          acc-stk-line.vat-rubl       = acc-stk-line.vat-rubl       + tt-stk-line.vat-rubl
          acc-stk-line.slt-base       = acc-stk-line.slt-base       + tt-stk-line.slt-base
          acc-stk-line.slt-rubl       = acc-stk-line.slt-rubl       + tt-stk-line.slt-rubl
          acc-stk-line.road-tax-base  = acc-stk-line.road-tax-base  + tt-stk-line.road-tax-base
          acc-stk-line.road-tax-rubl  = acc-stk-line.road-tax-rubl  + tt-stk-line.road-tax-rubl
          acc-stk-line.excise-base    = acc-stk-line.excise-base    + tt-stk-line.excise-base
          acc-stk-line.excise-rubl    = acc-stk-line.excise-rubl    + tt-stk-line.excise-rubl
          acc-stk-line.transport-base = acc-stk-line.transport-base + tt-stk-line.transport-base
          acc-stk-line.transport-rubl = acc-stk-line.transport-rubl + tt-stk-line.transport-rubl
          acc-stk-line.other-base     = acc-stk-line.other-base     + tt-stk-line.other-base
          acc-stk-line.other-rubl     = acc-stk-line.other-rubl     + tt-stk-line.other-rubl.
          else
          assign
          acc-stk-line.sum-base       = ?
          acc-stk-line.sum-rubl       = ?
          acc-stk-line.vat-base       = ?
          acc-stk-line.vat-rubl       = ?
          acc-stk-line.slt-base       = ?
          acc-stk-line.slt-rubl       = ?
          acc-stk-line.road-tax-base  = ?
          acc-stk-line.road-tax-rubl  = ?
          acc-stk-line.excise-base    = ?
          acc-stk-line.excise-rubl    = ?
          acc-stk-line.transport-base = ?
          acc-stk-line.transport-rubl = ?
          acc-stk-line.other-base     = ?
          acc-stk-line.other-rubl     = ?.
       end.
       WHEN 'cgdt':U or
       WHEN 'gdsr':U THEN
       assign
       acc-stk-line.sum-base-sale       = acc-stk-line.sum-base-sale       + tt-stk-line.sum-base
       acc-stk-line.sum-rubl-sale       = acc-stk-line.sum-rubl-sale       + tt-stk-line.sum-rubl
       acc-stk-line.vat-base-sale       = acc-stk-line.vat-base-sale       + tt-stk-line.vat-base
       acc-stk-line.vat-rubl-sale       = acc-stk-line.vat-rubl-sale       + tt-stk-line.vat-rubl
       acc-stk-line.slt-base-sale       = acc-stk-line.slt-base-sale       + tt-stk-line.slt-base
       acc-stk-line.slt-rubl-sale       = acc-stk-line.slt-rubl-sale       + tt-stk-line.slt-rubl
       acc-stk-line.road-tax-base-sale  = acc-stk-line.road-tax-base-sale  + tt-stk-line.road-tax-base
       acc-stk-line.road-tax-rubl-sale  = acc-stk-line.road-tax-rubl-sale  + tt-stk-line.road-tax-rubl
       acc-stk-line.excise-base-sale    = acc-stk-line.excise-base-sale    + tt-stk-line.excise-base
       acc-stk-line.excise-rubl-sale    = acc-stk-line.excise-rubl-sale    + tt-stk-line.excise-rubl
       acc-stk-line.transport-base-sale = acc-stk-line.transport-base-sale + tt-stk-line.transport-base
       acc-stk-line.transport-rubl-sale = acc-stk-line.transport-rubl-sale + tt-stk-line.transport-rubl
       acc-stk-line.other-base-sale     = acc-stk-line.other-base-sale     + tt-stk-line.other-base
       acc-stk-line.other-rubl-sale     = acc-stk-line.other-rubl-sale     + tt-stk-line.other-rubl.
       WHEN 'sadt':U or
       WHEN 'adsr':U THEN
       assign
       acc-stk-line.sum-base-doc       = acc-stk-line.sum-base-doc       + tt-stk-line.sum-base
       acc-stk-line.sum-rubl-doc       = acc-stk-line.sum-rubl-doc       + tt-stk-line.sum-rubl
       acc-stk-line.vat-base-doc       = acc-stk-line.vat-base-doc       + tt-stk-line.vat-base
       acc-stk-line.vat-rubl-doc       = acc-stk-line.vat-rubl-doc       + tt-stk-line.vat-rubl
       acc-stk-line.slt-base-doc       = acc-stk-line.slt-base-doc       + tt-stk-line.slt-base
       acc-stk-line.slt-rubl-doc       = acc-stk-line.slt-rubl-doc       + tt-stk-line.slt-rubl
       acc-stk-line.road-tax-base-doc  = acc-stk-line.road-tax-base-doc  + tt-stk-line.road-tax-base
       acc-stk-line.road-tax-rubl-doc  = acc-stk-line.road-tax-rubl-doc  + tt-stk-line.road-tax-rubl
       acc-stk-line.excise-base-doc    = acc-stk-line.excise-base-doc    + tt-stk-line.excise-base
       acc-stk-line.excise-rubl-doc    = acc-stk-line.excise-rubl-doc    + tt-stk-line.excise-rubl
       acc-stk-line.transport-base-doc = acc-stk-line.transport-base-doc + tt-stk-line.transport-base
       acc-stk-line.transport-rubl-doc = acc-stk-line.transport-rubl-doc + tt-stk-line.transport-rubl
       acc-stk-line.other-base-doc     = acc-stk-line.other-base-doc     + tt-stk-line.other-base
       acc-stk-line.other-rubl-doc     = acc-stk-line.other-rubl-doc     + tt-stk-line.other-rubl.
       otherwise do:
          message "Некорректный sum-type " varsadt " при просмотре архива(main-arr.i)." skip
                  "Ошибка в расчетах."
          view-as alert-box error.
       end.
    END CASE.
end.
  end.
end.
run waitfram-hide in this-procedure .
OPEN QUERY b-kind-type FOR EACH tt-kind-sum NO-LOCK.    OPEN QUERY BROWSE-1 FOR EACH acc-stk-line NO-LOCK.
display varqnty-start varqnty-end with frame F-Main.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE send-records :
  DEFINE INPUT PARAMETER p-tbl-list AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-rowid-list AS CHARACTER NO-UNDO.
  DEFINE VARIABLE i            AS INTEGER   NO-UNDO.
  DEFINE VARIABLE link-handle  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE rowid-string AS CHARACTER NO-UNDO.
  DO i = 1 TO NUM-ENTRIES(p-tbl-list):
      IF i > 1 THEN p-rowid-list = p-rowid-list + ",":U.
      CASE ENTRY(i, p-tbl-list):
    WHEN "tt-kind-sum":U THEN p-rowid-list = p-rowid-list +
        IF AVAILABLE tt-kind-sum THEN STRING(ROWID(tt-kind-sum))
        ELSE "?":U.
    WHEN "acc-stk-line":U THEN p-rowid-list = p-rowid-list +
        IF AVAILABLE acc-stk-line THEN STRING(ROWID(acc-stk-line))
        ELSE "?":U.
        OTHERWISE
        DO:
            RUN get-link-handle IN adm-broker-hdl (INPUT THIS-PROCEDURE,
                INPUT "RECORD-SOURCE":U, OUTPUT link-handle) NO-ERROR.
            IF link-handle NE "":U THEN
            DO:
                IF NUM-ENTRIES(link-handle) > 1 THEN
                    MESSAGE "send-records in ":U THIS-PROCEDURE:FILE-NAME
                            "encountered more than one RECORD-SOURCE.":U SKIP
                            "The first will be used.":U
                            VIEW-AS ALERT-BOX ERROR.
                RUN send-records IN WIDGET-HANDLE(ENTRY(1,link-handle))
                    (INPUT ENTRY(i, p-tbl-list), OUTPUT rowid-string).
                p-rowid-list = p-rowid-list + rowid-string.
            END.
            ELSE
            DO:
                MESSAGE "Requested table":U ENTRY(i, p-tbl-list)
                        "does not match tables in send-records":U
                        "in procedure":U THIS-PROCEDURE:FILE-NAME ".":U SKIP
                        "Check that objects are linked properly and that":U
                        "database qualification is consistent.":U
                    VIEW-AS ALERT-BOX ERROR.
                RETURN ERROR.
            END.
        END.
        END CASE.
    END.
END PROCEDURE.
PROCEDURE show_arh :
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
RUN request-attribute IN adm-broker-hdl                     (INPUT THIS-PROCEDURE,                                       INPUT 'Container-Source':U,                                 INPUT 'main-handle':U) NO-ERROR.                        if return-value = "" or return-value = ? or return-value = "?" then do:                        return error "Нет атрибута: " + "main-handle" + " для получения данных." .                    end.
assign varh_caller-main = widget-handle(return-value).
RUN request-attribute IN adm-broker-hdl                     (INPUT THIS-PROCEDURE,                                       INPUT 'Container-Source':U,                                 INPUT 'varis-calend':U) NO-ERROR.                        if return-value = "" or return-value = ? or return-value = "?" then do:                        return error "Нет атрибута: " + "varis-calend" + " для получения данных." .                    end.
assign varis-calend = integer(return-value).
RUN request-attribute IN adm-broker-hdl                     (INPUT THIS-PROCEDURE,                                       INPUT 'Container-Source':U,                                 INPUT 'varis-shift-num':U) NO-ERROR.                        if return-value = "" or return-value = ? or return-value = "?" then do:                        return error "Нет атрибута: " + "varis-shift-num" + " для получения данных." .                    end.
assign varis-shift-num = if return-value = 'yes' then yes else no.
RUN request-attribute IN adm-broker-hdl                     (INPUT THIS-PROCEDURE,                                       INPUT 'Container-Source':U,                                 INPUT 'vardate-start':U) NO-ERROR.                        if return-value = "" or return-value = ? or return-value = "?" then do:                        return error "Нет атрибута: " + "vardate-start" + " для получения данных." .                    end.
assign vardate-start = date(return-value).
RUN request-attribute IN adm-broker-hdl                     (INPUT THIS-PROCEDURE,                                       INPUT 'Container-Source':U,                                 INPUT 'vardate-end':U) NO-ERROR.                        if return-value = "" or return-value = ? or return-value = "?" then do:                        return error "Нет атрибута: " + "vardate-end" + " для получения данных." .                    end.
assign vardate-end = date(return-value).
RUN request-attribute IN adm-broker-hdl                     (INPUT THIS-PROCEDURE,                                       INPUT 'Container-Source':U,                                 INPUT 'varshift-start':U) NO-ERROR.                        if return-value = "" or return-value = ? or return-value = "?" then do:                        return error "Нет атрибута: " + "varshift-start" + " для получения данных." .                    end.
assign varshift-start = integer(return-value).
RUN request-attribute IN adm-broker-hdl                     (INPUT THIS-PROCEDURE,                                       INPUT 'Container-Source':U,                                 INPUT 'varshift-end':U) NO-ERROR.                        if return-value = "" or return-value = ? or return-value = "?" then do:                        return error "Нет атрибута: " + "varshift-end" + " для получения данных." .                    end.
assign varshift-end = integer(return-value).
RUN request-attribute IN adm-broker-hdl                     (INPUT THIS-PROCEDURE,                                       INPUT 'Container-Source':U,                                 INPUT 'varext-doc-type':U) NO-ERROR.                        if return-value = "" or return-value = ? or return-value = "?" then do:                        return error "Нет атрибута: " + "varext-doc-type" + " для получения данных." .                    end.
assign varext-doc-type = return-value.
RUN request-attribute IN adm-broker-hdl                     (INPUT THIS-PROCEDURE,                                       INPUT 'Container-Source':U,                                 INPUT 'rubl-base':U) NO-ERROR.                        if return-value = "" or return-value = ? or return-value = "?" then do:                        return error "Нет атрибута: " + "rubl-base" + " для получения данных." .                    end.
assign varrubl-base = integer(return-value).
  run calc-field-frame.
END PROCEDURE.
PROCEDURE state-changed :
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.
  CASE p-state:
    WHEN 'update-begin':U THEN DO:
        RUN dispatch('enable-fields':U).
        IF RETURN-VALUE = "ADM-ERROR":U THEN
        DO:
          RUN new-state('update-failed,TABLEIO-SOURCE':U).
          RUN new-state('update-complete':U).
        END.
        ELSE RUN new-state ('update':U).
    END.
    WHEN 'update-complete':U THEN DO:
        RUN new-state ('update-complete':U).
    END.
  END CASE.
END PROCEDURE.
FUNCTION func-excise RETURNS DECIMAL
  ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.excise-rubl.
                      else return bf_acc-stk-line.excise-base.
END FUNCTION.
FUNCTION func-excise-doc RETURNS DECIMAL
  ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.excise-rubl-doc.
                      else return bf_acc-stk-line.excise-base-doc.
END FUNCTION.
FUNCTION func-other RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.other-rubl.
                      else return bf_acc-stk-line.other-base.
END FUNCTION.
FUNCTION func-other-doc RETURNS DECIMAL
 ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.other-rubl-doc.
                      else return bf_acc-stk-line.other-base-doc.
END FUNCTION.
FUNCTION func-price-doc RETURNS DECIMAL
( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return (bf_acc-stk-line.sum-rubl-doc / bf_acc-stk-line.fact-qnty).
                      else return (bf_acc-stk-line.sum-base-doc / bf_acc-stk-line.fact-qnty).
END FUNCTION.
FUNCTION func-price-sale RETURNS DECIMAL
( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return (bf_acc-stk-line.sum-rubl-sale / bf_acc-stk-line.fact-qnty).
                      else return (bf_acc-stk-line.sum-base-sale / bf_acc-stk-line.fact-qnty).
END FUNCTION.
FUNCTION func-road-tax RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.road-tax-rubl.
                      else return bf_acc-stk-line.road-tax-base.
END FUNCTION.
FUNCTION func-road-tax-doc RETURNS DECIMAL
 ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.road-tax-rubl-doc.
                      else return bf_acc-stk-line.road-tax-base-doc.
END FUNCTION.
FUNCTION func-slt RETURNS DECIMAL
 ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.slt-rubl.
                      else return bf_acc-stk-line.slt-base.
END FUNCTION.
FUNCTION func-slt-doc RETURNS DECIMAL
( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.slt-rubl-doc.
                      else return bf_acc-stk-line.slt-base-doc.
END FUNCTION.
FUNCTION func-sum RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.sum-rubl.
                      else return bf_acc-stk-line.sum-base.
END FUNCTION.
FUNCTION func-sum-doc RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.sum-rubl-doc.
                      else return bf_acc-stk-line.sum-base-doc.
END FUNCTION.
FUNCTION func-sum-end RETURNS DECIMAL
  ( buffer bf_tt-kind-sum for tt-kind-sum ) :
  if varrubl-base = 1 then return bf_tt-kind-sum.sum-end-rubl.
                      else return bf_tt-kind-sum.sum-end-base.
END FUNCTION.
FUNCTION func-sum-end-sale RETURNS DECIMAL
  ( buffer bf_tt-kind-sum for tt-kind-sum ) :
  if varrubl-base = 1 then return bf_tt-kind-sum.sum-end-rubl-sale.
                      else return bf_tt-kind-sum.sum-end-base-sale.
END FUNCTION.
FUNCTION func-sum-sale RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.sum-rubl-sale.
                      else return bf_acc-stk-line.sum-base-sale.
END FUNCTION.
FUNCTION func-sum-start RETURNS DECIMAL
  ( buffer bf_tt-kind-sum for tt-kind-sum ) :
  if varrubl-base = 1 then return bf_tt-kind-sum.sum-start-rubl.
                      else return bf_tt-kind-sum.sum-start-base.
END FUNCTION.
FUNCTION func-sum-start-sale RETURNS DECIMAL
  ( buffer bf_tt-kind-sum for tt-kind-sum ) :
  if varrubl-base = 1 then return bf_tt-kind-sum.sum-start-rubl-sale.
                      else return bf_tt-kind-sum.sum-start-base-sale.
END FUNCTION.
FUNCTION func-transport RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.transport-rubl.
                      else return bf_acc-stk-line.transport-base.
END FUNCTION.
FUNCTION func-transport-doc RETURNS DECIMAL
  ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.transport-rubl-doc.
                      else return bf_acc-stk-line.transport-base-doc.
END FUNCTION.
FUNCTION func-vat RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.vat-rubl.
                      else return bf_acc-stk-line.vat-base.
END FUNCTION.
FUNCTION func-vat-doc RETURNS DECIMAL
    ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.vat-rubl-doc.
                      else return bf_acc-stk-line.vat-base-doc.
END FUNCTION.
