using ibs.th.gbl.storage.*.
DEFINE NEW SHARED BUFFER r-doc FOR rvs-doc.
define input parameter parparentproc as handle    no-undo.
define input parameter parlist-mode  as character no-undo.
define input parameter parstatus     as character no-undo.
define output parameter out-rec      as recid     no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Список документов сверки":U .
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table gds-list no-undo like ub.goods
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define    temp-table gds-list-hist no-undo
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
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define new global shared variable g#lib-rvs as handle no-undo.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-fltopend-rowid as rowid extent 18 no-undo .
procedure fltopend_fltopend :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
  do
  on error undo, return error
  :
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
assign
v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                   p-where-cond + chr(32)  +
                   p-use-indFIRST-query-tail + chr(32) +
                   p-use-ind-sort-clmn-by + chr(32) +
                   p-indexed-reposition
.
assign
glog = p-qh:query-prepare(v-prepare-string) no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
assign
glog = p-qh:query-open no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
  end.
end procedure.
procedure fltopend_fltfindd :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-index-phrase as character no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-recid as recid no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  glog = p-bh:find-by-rowid( p-rowid, p-lock) no-error.
  create buffer v-bh for table p-bh buffer-name p-bh:name.
  create query v-qh.
  v-qh:set-buffers(v-bh).
  v-prepare-string = substitute("for each &1 &2 &3"
                                  ,v-bh:name
                                  ,p-where-cond
                                  ,p-use-index-phrase).
  glog = v-qh:query-prepare(v-prepare-string) no-error.
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  if p-next then do:
    v-qh:reposition-to-rowid(p-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  v-recid = v-bh:recid no-error .
  delete object v-qh.
  delete object v-bh.
  return string(v-recid) .
end.
end procedure.
procedure fltopend_fltfindq :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
define output parameter p-fltopend-rowid as rowid extent 18 no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo extent 18.
define variable v-rowid as rowid no-undo extent 18.
define variable v-ii as integer no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  create query v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    create buffer v-bh[v-ii] for table p-qh:get-buffer-handle(v-ii) buffer-name p-qh:get-buffer-handle(v-ii):name .
    assign
    v-rowid[v-ii] = p-qh:get-buffer-handle(v-ii):rowid
    no-error.
    v-qh:add-buffer(v-bh[v-ii]).
  end.
  assign
  v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                    p-where-cond + chr(32)  +
                    p-use-indFIRST-query-tail + chr(32) +
                    p-use-ind-sort-clmn-by + chr(32) +
                    p-indexed-reposition
  .
  glog = v-qh:query-prepare( v-prepare-string) no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  if p-next then do:
    glog = v-qh:reposition-to-rowid(v-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  do v-ii = 1 to p-qh:num-buffers:
    assign
    p-fltopend-rowid[v-ii] = v-bh[v-ii]:rowid
    no-error.
  end.
  delete object v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    delete object v-bh[v-ii].
  end.
end.
end procedure.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
function is-gas returns logical
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
result = logical(c-value = 'metan':U) no-error.
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define NEW shared temp-table tt-susp-chk no-undo like ub.susp-chk .
define buffer buf-inv_trn-doc for ub.trn-doc .
define buffer buf-spi_trn-doc for ub.trn-doc .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function autorvs return char
    ( input p-rec as recid  ) :
    define variable p-autorvs as char no-undo.
    define buffer Buf_doc-attr for doc-attr.
    define buffer r-d          for rvs-doc.
    find first r-d no-lock where recid(r-d) = p-rec no-error.
    find first buf_doc-attr no-lock where r-d.rvs-code = buf_doc-attr.doc-code and buf_doc-attr.attr-code = "rvs-auto" and buf_doc-attr.attr-value = "Yes" no-error.
    if available buf_doc-attr then
    do :
        p-autorvs = 'а'.
    end.
    else
    do:
        if r-d.is-full = yes then
        do:
            p-autorvs =  "п" .
        end.
        else
        do :
            p-autorvs = " ".
        end.
    end.
    return ( p-autorvs ).
end function.
define temp-table autorvs no-undo
field attr-code like doc-attr.attr-code
field attr-value like doc-attr.attr-value
field rvs-code  like r-doc.rvs-code
field auto as logical
.
define variable br-handle        as handle    no-undo.
define variable bcol             as handle    extent 34 no-undo.
define variable ii               as integer.
define variable sch-field        as char      no-undo.
define variable del-list         as char      no-undo.
define variable mark             as char      no-undo.
define variable auto             as char      no-undo.
define variable hd-rvs           as handle    no-undo.
define variable varobj-type      like ub.rvs-doc.obj-type no-undo .
define variable varobj-code      like ub.rvs-doc.obj-code no-undo .
define variable varhost-code     like ub.rvs-doc.host-code no-undo .
define variable varstatus_       like ub.rvs-doc.status_ no-undo .
define variable vartest-asi      like ub.rvs-doc.rvs-type no-undo .
define variable is-vir           as logical   no-undo.
define variable v-value          as character no-undo.
define variable v-ok             as logical   no-undo.
define variable sort-column-name as character no-undo.
define variable filter-point     as character no-undo.
define variable varstr           as character no-undo.
define variable varrecid         as recid     no-undo.
define variable rvs-rec          as recid     no-undo.
define variable varlog           as logical   no-undo.
define variable p-auto           as char      no-undo.
define variable rvsinvstrObj     as class rvsinvstr no-undo.
FUNCTION mark-string RETURNS CHARACTER
    ( p-rec as recid )  FORWARD.
FUNCTION get-input-type RETURNS CHARACTER
    ( p-rec as recid )  FORWARD.
FUNCTION shift-name RETURNS CHARACTER
    ( p-rec as recid )  FORWARD.
DEFINE BUTTON b-add
     LABEL "Добавить":L
     SIZE 10 BY 1.
DEFINE BUTTON b-chg
     LABEL "Изменить":L
     SIZE 10 BY 1.
DEFINE BUTTON b-close
     LABEL "Закрыть":L
     SIZE 10 BY 1.
DEFINE BUTTON b-del
     LABEL "Удалить":L
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "Помощь":L
     SIZE 7 BY 1.
DEFINE BUTTON b-hist
     LABEL "История"
     SIZE 3 BY 1.
DEFINE BUTTON b-inv
     LABEL "Инвент."
     SIZE 10 BY 1.
DEFINE BUTTON b-lkp
     LABEL "Просмотр":L
     SIZE 10 BY 1.
DEFINE BUTTON b-mark
     LABEL "*":L
     SIZE 3 BY 1.
DEFINE BUTTON b-open
     LABEL "Открыть"
     SIZE 10 BY 1.
DEFINE BUTTON b-print
     LABEL "Печать":L
     SIZE 7 BY 1.
DEFINE BUTTON b-quit AUTO-GO
     LABEL "Выход":L
     SIZE 10 BY 1.
DEFINE BUTTON b-sch
     LABEL "&Фильтр":L
     SIZE 7 BY 1.
DEFINE BUTTON b-sel
     LABEL "Выбор":L
     SIZE 10 BY 1.
DEFINE BUTTON Btn_Copy
     LABEL "&Ст.Смен."
     SIZE 10 BY 1 TOOLTIP "Сделать сменную сверку на основе контрольной (полной)".
DEFINE VARIABLE ed-notes AS CHARACTER
     VIEW-AS EDITOR
     SIZE 99 BY 2
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE f-agnt-name AS CHARACTER FORMAT "X(19)":U
     LABEL "Исп"
      VIEW-AS TEXT
     SIZE 19.5 BY .67 NO-UNDO.
DEFINE VARIABLE f-boss-name AS CHARACTER FORMAT "X(19)":U
     LABEL "М-р"
      VIEW-AS TEXT
     SIZE 19.5 BY .67 NO-UNDO.
DEFINE VARIABLE f-cre-name AS CHARACTER FORMAT "X(19)":U
     LABEL "Опер"
      VIEW-AS TEXT
     SIZE 19.5 BY .67 NO-UNDO.
DEFINE VARIABLE f-obj-name AS CHARACTER FORMAT "X(13)":U
     LABEL "Объект"
      VIEW-AS TEXT
     SIZE 62.5 BY .67 NO-UNDO.
DEFINE VARIABLE f-wrkr-name AS CHARACTER FORMAT "X(19)":U
     LABEL "Кл-к"
      VIEW-AS TEXT
     SIZE 19.5 BY .67 NO-UNDO.
DEFINE NEW SHARED QUERY br-r-docs for r-doc SCROLLING.
DEFINE BROWSE br-r-docs
  QUERY br-r-docs DISPLAY
      mark-string (recid( r-doc)) @ mark COLUMN-LABEL '*'  FORMAT "x(1)"
     (substring (r-doc.rvs-type, 1, 9))  COLUMN-LABEL ' Tип '  FORMAT "x(9)"
     autorvs (recid(r-doc))  COLUMN-LABEL ' '  format "x(1)"
     get-input-type (recid( r-doc)) COLUMN-LABEL 'тв'  format "x(2)"
     r-doc.status_  column-label 'Стат'  format "x(5)"
     r-doc.rvs-code  column-label 'Документ'  format "x(12)"
     (substring ((string (r-doc.doc-date)), 1, 5))  COLUMN-LABEL 'Дата'  format "x(5)"
     r-doc.fact-date  COLUMN-LABEL 'Факт'
     string(r-doc.fact-time,'hh:mm:ss')  COLUMN-LABEL 'Время'
     r-doc.out-code  column-label 'Документ'
     (substring ((string (r-doc.shift-date)), 1, 5)) column-label 'Смена' format "x(5)"
     shift-name (recid(r-doc)) column-label '№' format "x(6)"
     r-doc.state-measure-qnty
     r-doc.measure-qnty
     r-doc.state-brutto-qnty
     r-doc.brutto-qnty
     r-doc.system-qnty
     r-doc.system-cli-qnty
     r-doc.system-cli-avrg-qnty
     r-doc.measure-cli-qnty format "->>,>>>,>>>,>>>.<<<"
     r-doc.state-measure-cli-qnty format "->>,>>>,>>>,>>>.<<<"
     r-doc.brutto-cli-qnty
     r-doc.state-brutto-cli-qnty
     r-doc.meas-mh-qnty format "->>,>>>,>>>,>>>.<<<"
     r-doc.state-mh-qnty format "->>,>>>,>>>,>>>.<<<"
     r-doc.meas-am-qnty format "->>,>>>,>>>,>>>.<<<"
     r-doc.state-am-qnty format "->>,>>>,>>>,>>>.<<<"
     r-doc.meas-cf-qnty
     r-doc.state-cf-qnty
     r-doc.level-petrol
     r-doc.state-level-petrol format "->>,>>>,>>>.<<<"
     r-doc.level-total
     r-doc.state-level-total
     r-doc.level-water
     r-doc.state-level-water
     ENABLE r-doc.state-level-water
    WITH SEPARATORS SIZE 99 BY 16.75.
DEFINE FRAME d-all-r-docs
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 14
     b-add AT ROW 1 COL 24
     b-lkp AT ROW 2 COL 24
     b-chg AT ROW 2 COL 34
     b-del AT ROW 2 COL 44
     b-close AT ROW 1 COL 34
     b-open AT ROW 1 COL 44
     b-hist AT ROW 1 COL 89.5 WIDGET-ID 64
     b-help AT ROW 1 COL 92.5
     Btn_Copy AT ROW 2 COL 54
     b-inv AT ROW 1 COL 74
     b-sch AT ROW 2 COL 85.5
     b-print AT ROW 2 COL 92.5
     br-r-docs AT ROW 3 COL 1
     ed-notes AT ROW 21.5 COL 1 NO-LABEL
     f-boss-name AT ROW 20 COL 5 COLON-ALIGNED
     f-obj-name AT ROW 20 COL 35 COLON-ALIGNED
     f-agnt-name AT ROW 20.75 COL 5 COLON-ALIGNED
     f-wrkr-name AT ROW 20.75 COL 35 COLON-ALIGNED
     f-cre-name AT ROW 20.75 COL 65 COLON-ALIGNED
     SPACE(13.50) SKIP(2.08)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>".
ASSIGN
       FRAME d-all-r-docs:SCROLLABLE       = FALSE
       FRAME d-all-r-docs:HIDDEN           = TRUE.
ASSIGN
       br-r-docs:NUM-LOCKED-COLUMNS IN FRAME d-all-r-docs     = 4
       br-r-docs:COLUMN-RESIZABLE IN FRAME d-all-r-docs       = TRUE.
ON WINDOW-CLOSE OF FRAME d-all-r-docs
DO:
        APPLY "END-ERROR":U TO SELF.
    END.
ON CHOOSE OF b-add IN FRAME d-all-r-docs
DO:
        define buffer bf_icnt-doc for ub.icnt-doc.
        define buffer bf_rvs-doc  for ub.rvs-doc.
        find first bf_icnt-doc no-lock
            where bf_icnt-doc.obj-type  = v-cntxt-obj-type
            and bf_icnt-doc.obj-code  = v-cntxt-obj-code
            and bf_icnt-doc.doc-type  = 'инв-сч-трк':U
            AND bf_icnt-doc.status_  <> 'факт':U
            no-error.
        if available bf_icnt-doc then
        do:
            message
                "Имеется не закрытый документ инвентаризации счетчиков ТРК " bf_icnt-doc.doc-code " ."
                view-as alert-box error.
            return no-apply.
        end.
        find first bf_rvs-doc no-lock
            where bf_rvs-doc.obj-type =  v-cntxt-obj-type
            and bf_rvs-doc.obj-code =  v-cntxt-obj-code
            and bf_rvs-doc.status_  <> 'факт':U
            and ( bf_rvs-doc.rvs-type = 'смена':U
            or bf_rvs-doc.rvs-type = 'контроль':U
            and bf_rvs-doc.is-full  = yes
            )
            no-error.
        if available bf_rvs-doc then
        do:
            message
                "Имеется не закрытый документ сверки " bf_rvs-doc.rvs-code " ."
                view-as alert-box error.
            return no-apply.
        end.
        assign
            rvs-rec = ?
            .
        do
            on stop undo, return no-apply
            :
            run str/rvs-add.w
                ( input parparentproc
                ,input 'ДОБАВЛЕНИЕ':U
                ,output rvs-rec
                ) no-error.
            if error-status :error then
            do:
                undo, return no-apply.
            end.
        end.
        if rvs-rec = ? then
        do:
            return no-apply.
        end.
        message
            "Новый документ сверки добавлен в Базу Данных."
            view-as alert-box information.
        run UI-on in this-procedure.
    END.
ON CHOOSE OF b-chg IN FRAME d-all-r-docs
DO:
        define buffer bf_trn-doc for ub.trn-doc.
        if not available r-doc then do:     message       "Неправильный выбор документа сверки."       view-as alert-box .     return no-apply.   end.   else do:     assign       rvs-rec = recid (r-doc)     .   end.
  if r-doc.status_ = 'факт':U
    or r-doc.status_ = 'нередакт':U
  then do:
        message
            "Данный документ сверки закрыт по факту или не может быть обработан в этом списке."
            view-as alert-box.
        return no-apply.
    end.
find first bf_trn-doc
    where bf_trn-doc.out-code = r-doc.rvs-code
    no-error.
if available bf_trn-doc then
do:
    message
        "По сверке есть инвентаризация. Изменять сверку нельзя."
        view-as alert-box.
    return no-apply.
end.
assign
    rvs-rec = recid( r-doc )
    .
run str/rvs-doc.w
    ( input        parparentproc
    ,input        'ИЗМЕНЕНИЕ':U
    ,input        r-doc.rvs-type
    ,input        no
    ,input-output rvs-rec
    ) no-error.
if error-status :error then
do:
    find r-doc no-lock
        where recid (r-doc) = rvs-rec
        .
    return no-apply.
end.
apply "entry" to br-r-docs in frame d-all-r-docs.
run UI-on in this-procedure .
END.
ON CHOOSE OF b-close IN FRAME d-all-r-docs
DO:
        define variable varchg-inv as logical   no-undo.
        define variable v-inv-doc  as character no-undo .
        if not available r-doc then do:     message       "Неправильный выбор документа сверки."       view-as alert-box .     return no-apply.   end.   else do:     assign       rvs-rec = recid (r-doc)     .   end.
  if r-doc.status_ = 'факт':U
    or r-doc.status_ = 'нередакт':U
  then do:
        message
            "Данный документ сверки закрыт по факту или не может быть обработан в этом списке."
            view-as alert-box.
        return no-apply.
    end.
if r-doc.status_ = 'новый':U then
do:
    assign
        varlog = no
        .
    message
        "Вы хотите завершить редактирование документа сверки?"
        view-as alert-box question buttons yes-no update varlog .
    if varlog <> yes then
    do:
        return no-apply.
    end.
    tr:
    do transaction
        on error   undo tr, leave
        on end-key undo tr, leave
        on stop    undo tr, leave
        :
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_rvsclose in g#lib-rvs ( input parparentproc ,
                      input recid(r-doc) ,
                      input yes ) no-error .
      if error-status :error then do:
        message
          "Ошибка при закрытии документа сверки." skip
          error-status:get-message(1) skip
          return-value
          view-as alert-box error.
        run userlogrvs(58, return-value + error-status:get-message(1) ) .
        undo tr, leave.
      end.
    end.
end.
else
do:
    find first buf-inv_trn-doc no-lock
        where buf-inv_trn-doc.out-code = r-doc.rvs-code
        no-error.
    if ambiguous buf-inv_trn-doc then
    do:
        message
            "Найдено более одного складского документа связанного со сверкой."
            view-as alert-box error.
        return no-apply.
    end.
    if available buf-inv_trn-doc then
    do:
        if buf-inv_trn-doc.doc-type <> 'инв':U then
        do:
            message
                "Документ связанный с документом сверки не яв-ся инвентаризацией."
                view-as alert-box error.
            return no-apply.
        end.
        if buf-inv_trn-doc.status_ <> 'нередакт':U
            or buf-inv_trn-doc.flag_ <> yes
            then
        do:
            message
                substitute( "Ошибка в документе инвентаризации &1 по сверке.", buf-inv_trn-doc.doc-code ) skip
                substitute( "Связанный со сверкой документ инвентаризации не находится в статусе &1", 'нередакт':U )
                view-as alert-box error.
            return no-apply.
        end.
        assign
            varstr    = " документ инвентаризации"
            v-inv-doc = buf-inv_trn-doc.doc-code
            .
    end.
    assign
        varlog = no
        .
    message
        substitute( "Вы хотите закрыть документ сверки &1?", (if varstr <> "" then "и" else "") + varstr )
        view-as alert-box question buttons yes-no update varlog.
    if varlog <> yes then
    do:
        return no-apply.
    end.
    find first ub.rvs-line no-lock
        where ub.rvs-line.rvs-code           = r-doc.rvs-code
        and ub.rvs-line.state-measure-qnty = ?
        no-error.
    if available ub.rvs-line then
    do:
        find first ub.goods no-lock
            where ub.goods.gds-code = ub.rvs-line.gds-code.
        run placelib_get-attr(input "place-virtual"
            ,input rvs-line.obj-code
            ,input rvs-line.obj-type
            ,input rvs-line.pl-code
            ,output v-value
            ,output v-ok) no-error.
        is-vir = if (v-ok and logical(v-value)) then true else false.
        if not is-gas(ub.rvs-line.gds-code) and not is-vir then
        do:
            message
                substitute( "Не заданы фактические остатки по товару &1 (&2)", ub.goods.gds-code, ub.goods.gds-name )
                view-as alert-box error.
            return no-apply.
        end.
    end.
    tr:
    do transaction
        on error   undo tr, leave
        on end-key undo tr, leave
        on stop    undo tr, leave
        :
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_rvsclose in g#lib-rvs ( input parparentproc ,
                      input recid(r-doc) ,
                      input yes ) no-error .
        if error-status :error then
        do:
            message
                "Ошибка при закрытии документа сверки." skip
                error-status:get-message(1) skip
                return-value
                view-as alert-box error.
            run userlogrvs(58, return-value + error-status:get-message(1) ) .
            undo tr, leave.
        end.
        release r-doc no-error .
        if error-status :error then
        do:
            message
                "Ошибка при закрытии документа сверки." skip
                error-status:get-message(1) skip
                return-value
                view-as alert-box error.
            undo tr, leave.
        end.
        find first buf-inv_trn-doc exclusive-lock
            where buf-inv_trn-doc.doc-code = v-inv-doc
            no-error.
        if available buf-inv_trn-doc then
        do:
            assign
                buf-inv_trn-doc.status_ = 'разрешен':U
                buf-inv_trn-doc.flag_   = yes
                .
    define variable is-pos   as logical   no-undo .
    define variable is-date  as logical   no-undo .
    define variable is-fio   as logical   no-undo .
    define variable is-check as logical   no-undo .
    define variable is-mes   as character no-undo .
    define buffer fio_inv-doc-attr    for ub.inv-doc-attr .
    define buffer pos_inv-doc-attr    for ub.inv-doc-attr .
    define buffer prikaz_inv-doc-attr for ub.inv-doc-attr .
    find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = v-inv-doc and
      ub.inv-doc-attr.attr-code = "invTech" and
      ub.inv-doc-attr.attr-value = string(true) no-error .
    if not available (ub.inv-doc-attr) then
    do:
      if not can-find (first prikaz_inv-doc-attr no-lock where prikaz_inv-doc-attr.doc-code = v-inv-doc and
        prikaz_inv-doc-attr.attr-code = 'trdcattr-prikaz-date':U and
        prikaz_inv-doc-attr.attr-value <> "") then
      do:
        is-date = true .
        is-check = true .
      end.
      if not can-find (first fio_inv-doc-attr no-lock where fio_inv-doc-attr.doc-code = v-inv-doc and
        (fio_inv-doc-attr.attr-code = 'trdcattr-fio-agent':U or
        fio_inv-doc-attr.attr-code = 'trdcattr-fio-player1':U or
        fio_inv-doc-attr.attr-code = 'trdcattr-fio-player2':U or
        fio_inv-doc-attr.attr-code = 'trdcattr-fio-player3':U) and
        fio_inv-doc-attr.attr-value <> "") then
      do:
        is-fio = true .
        is-check = true .
      end.
      if not can-find (first fio_inv-doc-attr no-lock where fio_inv-doc-attr.doc-code = v-inv-doc and
        (fio_inv-doc-attr.attr-code = 'trdcattr-pos-agent':U or
        fio_inv-doc-attr.attr-code = 'trdcattr-pos-player1':U or
        fio_inv-doc-attr.attr-code = 'trdcattr-pos-player2':U or
        fio_inv-doc-attr.attr-code = 'trdcattr-pos-player3':U) and
        fio_inv-doc-attr.attr-value <> "")then
      do:
        is-pos = true .
        is-check = true .
      end.
      if is-check then
      do:
        is-mes = "Ошибка при закрытии документа инвентаризации." .
        if is-date then
        do:
          is-mes = is-mes + chr(10) + "Не указана дата приказа." .
        end.
        if is-fio then
        do:
          is-mes = is-mes + chr(10) + "Не указано ФИО." .
        end.
        if is-pos then
        do:
          is-mes = is-mes + chr(10) + "Не указана должность." .
        end.
      end.
      find first fio_inv-doc-attr no-lock where
        fio_inv-doc-attr.doc-code = v-inv-doc and
        fio_inv-doc-attr.attr-code = 'trdcattr-fio-agent':U and
        fio_inv-doc-attr.attr-value <> "" no-error .
      if not available (fio_inv-doc-attr) then
      do:
        find first pos_inv-doc-attr no-lock where
          pos_inv-doc-attr.doc-code = v-inv-doc and
          pos_inv-doc-attr.attr-code = 'trdcattr-pos-agent':U and
          pos_inv-doc-attr.attr-value <> "" no-error .
        if available (pos_inv-doc-attr) then
        do:
          if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." .
          is-mes = is-mes + "Не заполнена ФИО председателя комиссии." + chr(10).
        end.
      end.
      else
      do:
        find first pos_inv-doc-attr no-lock where
          pos_inv-doc-attr.doc-code = v-inv-doc and
          pos_inv-doc-attr.attr-code = 'trdcattr-pos-agent':U and
          pos_inv-doc-attr.attr-value <> "" no-error .
        if not available (pos_inv-doc-attr) then
        do:
          if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." .
          is-mes = is-mes + "Не заполнена должность председателя комиссии." + chr(10).
        end.
      end.
      find first fio_inv-doc-attr no-lock where
        fio_inv-doc-attr.doc-code = v-inv-doc and
        fio_inv-doc-attr.attr-code = 'trdcattr-fio-player1':U and
        fio_inv-doc-attr.attr-value <> "" no-error .
      if not available (fio_inv-doc-attr) then
      do:
        find first pos_inv-doc-attr no-lock where
          pos_inv-doc-attr.doc-code = v-inv-doc and
          pos_inv-doc-attr.attr-code = 'trdcattr-pos-player1':U and
          pos_inv-doc-attr.attr-value <> "" no-error .
        if available (pos_inv-doc-attr) then
        do:
          if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." .
          is-mes = is-mes + "Не заполнена ФИО первого участника комиссии." + chr(10).
        end.
      end.
      else
      do:
        find first pos_inv-doc-attr no-lock where
          pos_inv-doc-attr.doc-code = v-inv-doc and
          pos_inv-doc-attr.attr-code = 'trdcattr-pos-player1':U and
          pos_inv-doc-attr.attr-value <> "" no-error .
        if not available (pos_inv-doc-attr) then
        do:
          if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." .
          is-mes = is-mes + "Не заполнена должность первого участника комиссии." + chr(10).
        end.
      end.
      find first fio_inv-doc-attr no-lock where
        fio_inv-doc-attr.doc-code = v-inv-doc and
        fio_inv-doc-attr.attr-code = 'trdcattr-fio-player2':U and
        fio_inv-doc-attr.attr-value <> "" no-error .
      if not available (fio_inv-doc-attr) then
      do:
        find first pos_inv-doc-attr no-lock where
          pos_inv-doc-attr.doc-code = v-inv-doc and
          pos_inv-doc-attr.attr-code = 'trdcattr-pos-player2':U and
          pos_inv-doc-attr.attr-value <> "" no-error .
        if available (pos_inv-doc-attr) then
        do:
          if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." .
          is-mes = is-mes + "Не заполнена ФИО второго участника комиссии." + chr(10).
        end.
      end.
      else
      do:
        find first pos_inv-doc-attr no-lock where
          pos_inv-doc-attr.doc-code = v-inv-doc and
          pos_inv-doc-attr.attr-code = 'trdcattr-pos-player2':U and
          pos_inv-doc-attr.attr-value <> "" no-error .
        if not available (pos_inv-doc-attr) then
        do:
          if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." .
          is-mes = is-mes + "Не заполнена должность второго участника комиссии." + chr(10).
        end.
      end.
      find first fio_inv-doc-attr no-lock where
        fio_inv-doc-attr.doc-code = v-inv-doc and
        fio_inv-doc-attr.attr-code = 'trdcattr-fio-player3':U and
        fio_inv-doc-attr.attr-value <> "" no-error .
      if not available (fio_inv-doc-attr) then
      do:
        find first pos_inv-doc-attr no-lock where
          pos_inv-doc-attr.doc-code = v-inv-doc and
          pos_inv-doc-attr.attr-code = 'trdcattr-pos-player3':U and
          pos_inv-doc-attr.attr-value <> "" no-error .
        if available (pos_inv-doc-attr) then
        do:
          if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." .
          is-mes = is-mes + "Не заполнена ФИО третьего участника комиссии." + chr(10).
        end.
      end.
      else
      do:
        find first pos_inv-doc-attr no-lock where
          pos_inv-doc-attr.doc-code = v-inv-doc and
          pos_inv-doc-attr.attr-code = 'trdcattr-pos-player3':U and
          pos_inv-doc-attr.attr-value <> "" no-error .
        if not available (pos_inv-doc-attr) then
        do:
          if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." .
          is-mes = is-mes + "Не заполнена должность третьего участника комиссии." + chr(10).
        end.
      end.
      if is-mes <> "" then do:
      message
        is-mes
        view-as alert-box .
      undo tr, leave.
      end.
    end.
            run str/trn-stat.p
                ( input parparentproc
                , input this-procedure
                , input '<закрытие документа>':U
                , input v-inv-doc
                , input ?
                , input v-cntxt-db-num
                , input ?
                , input ?
                , input ?
                , input ?
                , input yes
                , output varchg-inv
                , output table gds-list
                ) no-error.
            if error-status :error then
            do:
                message
                    "Не удалось закрыть инвентаризацию." skip
                    return-value                         skip
                    error-status :get-message(1)         skip
                    view-as alert-box error.
                undo tr, leave.
            end.
            release buf-inv_trn-doc no-error .
            if error-status :error then
            do:
                message
                    "Ошибка при закрытии документа интвентаризации." skip
                    error-status:get-message(1) skip
                    return-value
                    view-as alert-box error.
                undo tr, leave.
            end.
            find first buf-spi_trn-doc exclusive-lock
                where buf-spi_trn-doc.out-code = v-inv-doc
                and buf-spi_trn-doc.ext-doc-type = 'we':U
                no-error .
            if available buf-spi_trn-doc then
            do:
                assign
                    buf-spi_trn-doc.status_ = 'разрешен':U
                    buf-spi_trn-doc.flag_   = yes
                    .
                run str/trn-stat.p
                    ( input parparentproc
                    , input this-procedure
                    , input '<закрытие документа>':U
                    , input buf-spi_trn-doc.doc-code
                    , input ?
                    , input v-cntxt-db-num
                    , input ?
                    , input ?
                    , input ?
                    , input ?
                    , input yes
                    , output varchg-inv
                    , output table gds-list
                    ) no-error.
                if error-status :error then
                do:
                    message
                        "Не удалось закрыть документ списания." skip
                        return-value                            skip
                        error-status:get-message(1)             skip
                        view-as alert-box error.
                    undo tr, leave.
                end.
                release buf-spi_trn-doc no-error .
                if error-status :error then
                do:
                    message
                        "Ошибка при закрытии документа списания." skip
                        error-status:get-message(1) skip
                        return-value
                        view-as alert-box error.
                    undo tr, leave.
                end.
            end.
        end.
    end.
end.
find first r-doc no-lock
    where recid (r-doc) = rvs-rec
    .
run UI-on in this-procedure .
END.
ON CHOOSE OF b-del IN FRAME d-all-r-docs
DO:
    define variable v-person as character no-undo.
    define variable v-vid-action as integer  no-undo .
    define variable v-vid-param  as longchar no-undo .
    define variable v-mess as char no-undo.
    define variable p-rvs-doc as character no-undo.
        if not available r-doc then
        do:
            message "Не выбрана сверка, которую нужно удалить." view-as alert-box.
            return no-apply.
        end.
                p-rvs-doc = r-doc.rvs-code.
        run proc-del in this-procedure
            no-error.
        if error-status :error then
        do:
    run userlogrvs(60, return-value + error-status:get-message(1) ) no-error.
        if error-status :error
            then
        do:
            message substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                , chr(10)
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) )
                view-as alert-box.
            return no-apply.
        end.
    end.
        run openbr in this-procedure .
    END.
ON CHOOSE OF b-hist IN FRAME d-all-r-docs
DO:
    define variable v-list as character no-undo.
  if available r-doc then do:
    run str/rvscdocs.w ( input        parparentproc,
                     input        "":U,
                     input        "one":U,
                     input        r-doc.rvs-code,
                     input-output v-list                  ).
  end.
END.
ON CHOOSE OF b-inv IN FRAME d-all-r-docs
DO:
  define variable v-docs-info as character no-undo .
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_inventory_add':U
    ,input  'object':U
    ,input  r-doc.host-code
    ,input  r-doc.obj-type
    ,input  r-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
    if varlog <> yes then do:
      return no-apply.
    end.
  if not available r-doc then do:     message       "Неправильный выбор документа сверки."       view-as alert-box .     return no-apply.   end.   else do:     assign       rvs-rec = recid (r-doc)     .   end.
  if r-doc.status_ <> 'разрешен':U then do:
        message
            substitute( "Инвентаризацию можно проводить только по документам сверки в статусе &1.", 'разрешен':U )
            view-as alert-box.
        return no-apply.
    end.
find first ub.rvs-line no-lock
    where ub.rvs-line.rvs-code           = r-doc.rvs-code
    and ub.rvs-line.state-measure-qnty = ?
    no-error.
if available ub.rvs-line then
do:
    find first ub.goods no-lock
        where ub.goods.gds-code = ub.rvs-line.gds-code.
    run placelib_get-attr(input "place-virtual"
        ,input rvs-line.obj-code
        ,input rvs-line.obj-type
        ,input rvs-line.pl-code
        ,output v-value
        ,output v-ok) no-error.
    is-vir = if (v-ok and logical(v-value)) then true else false.
    if not is-gas(ub.rvs-line.gds-code) and not is-vir then
    do:
        message
            substitute( "Не заданы фактические остатки по товару &1 (&2)", ub.goods.gds-code, ub.goods.gds-name )
            view-as alert-box error.
        return no-apply.
    end.
end.
find first buf-inv_trn-doc no-lock
    where buf-inv_trn-doc.out-code = r-doc.rvs-code
    no-error.
if ambiguous buf-inv_trn-doc then
do:
    message
        "Найдено более одного складского документа связанного со сверкой."
        view-as alert-box error.
    return no-apply.
end.
if available buf-inv_trn-doc then
do:
    if buf-inv_trn-doc.doc-type <> 'инв':U then
    do:
        message
            "Документ связанный с документом сверки не яв-ся инвентаризацией."
            view-as alert-box error.
        return no-apply.
    end.
    if buf-inv_trn-doc.status_ <> 'нередакт':U
        or buf-inv_trn-doc.flag_ <> yes
        then
    do:
        message
            substitute( "Ошибка в документе инвентаризации &1 по сверке.", buf-inv_trn-doc.doc-code ) skip
            substitute( "Связанный со сверкой документ инвентаризации не находится в статусе &1", 'нередакт':U )
            view-as alert-box error.
        return no-apply.
    end.
    assign
        varstr = " документ инвентаризации"
        .
end.
if available buf-inv_trn-doc then
do:
    assign
        varlog = no.
    message
        "Вы хотите удалить документ инвентаризации?"
        view-as alert-box question buttons yes-no update varlog.
    if varlog <> yes then
    do:
        return no-apply.
    end.
    run delete-doc-inv in this-procedure
        ( input recid(buf-inv_trn-doc)
        ) no-error.
    if error-status :error then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка при удалении привязанных документов" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
    end.
    else
    do:
        message
            "Удаление завершено."
            view-as alert-box information.
    end.
end.
else
do:
    run str/rvscrdcs.p
        ( input parparentproc
        ,input rowid( r-doc )
        ,output v-docs-info
        ) no-error.
    if error-status :error then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка при создании документов" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
    end.
  end.
END.
ON CHOOSE OF b-lkp IN FRAME d-all-r-docs
DO:
        br-handle = br-r-docs:handle.
        if not available r-doc then do:     message       "Неправильный выбор документа сверки."       view-as alert-box .     return no-apply.   end.   else do:     assign       rvs-rec = recid (r-doc)     .   end.
  case r-doc.rvs-type
            :
    when 'перед_док':U
    or when 'после_док':U
    then do:
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-on-doc_lookup':U
    ,input  'object':U
    ,input  r-doc.host-code
    ,input  r-doc.obj-type
    ,input  r-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
end.
    when 'смена':U then do:
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-shift_lookup':U
    ,input  'object':U
    ,input  r-doc.host-code
    ,input  r-doc.obj-type
    ,input  r-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
end.
    when 'контроль':U then do:
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-control_lookup':U
    ,input  'object':U
    ,input  r-doc.host-code
    ,input  r-doc.obj-type
    ,input  r-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
end.
    otherwise do:
message
    vss-workfile vss-revision vss-description skip
    "Неизвестный тип документа сверки" skip
    "Тип документа сверки" r-doc.rvs-type skip
    "Код документа сверки" r-doc.rvs-code skip
    view-as alert-box error .
undo, return no-apply .
end.
end case .
if varlog <> yes then
do:
    return no-apply.
end.
do
    on stop undo, return no-apply
    :
    assign
        rvs-rec = recid( r-doc ).
    run str/rvs-doc.w
        ( input        parparentproc
        ,input        'ПРОСМОТР':U
        ,input        r-doc.rvs-type
        ,input        no
        ,input-output rvs-rec
        ) no-error.
    if error-status :error then
    do:
        return no-apply.
    end.
end.
if br-handle = ? then
do:
    reposition br-r-docs to recid rvs-rec no-error.
end.
apply "entry" to br-r-docs in frame d-all-r-docs.
apply "value-changed" to br-r-docs in frame d-all-r-docs.
END.
ON CHOOSE OF b-mark IN FRAME d-all-r-docs
DO:
        run local-mark in this-procedure .
        assign
            varlog = br-r-docs:select-next-row ()
            .
        apply "entry" to br-r-docs in frame d-all-r-docs.
    END.
ON CHOOSE OF b-open IN FRAME d-all-r-docs
DO:
        if not available r-doc then do:     message       "Неправильный выбор документа сверки."       view-as alert-box .     return no-apply.   end.   else do:     assign       rvs-rec = recid (r-doc)     .   end.
  if r-doc.status_ <> 'разрешен':U then do:
        message
            "Данный документ сверки закрыт по факту или не может быть обработан в этом списке."
            view-as alert-box error .
        return no-apply.
    end.
find first buf-inv_trn-doc no-lock
    where buf-inv_trn-doc.out-code = r-doc.rvs-code
    no-error.
if ambiguous buf-inv_trn-doc then
do:
    message
        "Найдено более одного складского документа связанного со сверкой."
        view-as alert-box error.
    return no-apply.
end.
if available buf-inv_trn-doc then
do:
    if buf-inv_trn-doc.doc-type <> 'инв':U then
    do:
        message
            "Документ связанный с документом сверки не яв-ся инвентаризацией."
            view-as alert-box error.
        return no-apply.
    end.
    if buf-inv_trn-doc.status_ <> 'нередакт':U
        or buf-inv_trn-doc.flag_ <> yes
        then
    do:
        message
            substitute( "Ошибка в документе инвентаризации &1 по сверке.", buf-inv_trn-doc.doc-code ) skip
            substitute( "Связанный со сверкой документ инвентаризации не находится в статусе &1", 'нередакт':U )
            view-as alert-box error.
        return no-apply.
    end.
    assign
        varstr = " документ инвентаризации"
        .
end.
assign
    varlog = no
    .
message
    substitute( "Вы хотите открыть документ сверки &1?", (if varstr <> "" then "и" else "") + varstr ) skip
    view-as alert-box question buttons yes-no update varlog.
if varlog <> yes then
do:
    return no-apply.
end.
tr:
do transaction
    on error   undo tr, return no-apply
    on end-key undo tr, return no-apply
    on stop    undo tr, return no-apply
    :
    if available buf-inv_trn-doc then
    do:
        run delete-doc-inv in this-procedure
            ( input recid(buf-inv_trn-doc)
            ) no-error.
        if error-status :error then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при удалении привязанных документов" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            undo tr, return no-apply .
        end.
    end.
    run str/rvs-stat.p
        ( input parparentproc
        ,input recid(r-doc)
        ,input "open":U
        ) no-error.
    if error-status :error then
    do:
        message
            "Ошибка при изменении статуса." skip
            return-value
            view-as alert-box error.
        undo tr, return no-apply.
    end.
    release r-doc no-error .
    if error-status :error then
    do:
        message
            "Ошибка при открытии документа сверки." skip
            error-status:get-message(1) skip
            return-value
            view-as alert-box error.
        undo tr, leave.
    end.
end.
find r-doc no-lock
    where recid (r-doc) = rvs-rec
    .
run UI-on in this-procedure .
END.
ON CHOOSE OF b-print IN FRAME d-all-r-docs
DO:
        if not available r-doc then do:     message       "Неправильный выбор документа сверки."       view-as alert-box .     return no-apply.   end.   else do:     assign       rvs-rec = recid (r-doc)     .   end.
  assign rvs-rec = recid (r-doc).
        case r-doc.rvs-type
            :
            when 'перед_док':U
            or
            when 'после_док':U
            then
                do:
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-on-doc_print':U
    ,input  'object':U
    ,input  r-doc.host-code
    ,input  r-doc.obj-type
    ,input  r-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
                end.
            when 'смена':U then
                do:
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-shift_print':u
    ,input  'object':U
    ,input  r-doc.host-code
    ,input  r-doc.obj-type
    ,input  r-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
                end.
            when 'контроль':U then
                do:
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-control_print':u
    ,input  'object':U
    ,input  r-doc.host-code
    ,input  r-doc.obj-type
    ,input  r-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
                end.
            otherwise
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Неизвестный тип документа сверки" skip
                    "Тип документа сверки" r-doc.rvs-type skip
                    "Код документа сверки" r-doc.rvs-code skip
                    view-as alert-box error .
                undo, return no-apply .
            end.
        end case .
        if varlog <> yes then
        do:
            return no-apply.
        end.
        run rep/r-rvsdoc.p
            ( input parparentproc
            ,input rvs-rec
            ).
        apply "entry" to br-r-docs in frame d-all-r-docs.
    END.
ON CHOOSE OF b-quit IN FRAME d-all-r-docs
DO:
        assign
            rvs-rec = ?.
    END.
ON CHOOSE OF b-sch IN FRAME d-all-r-docs
DO:
        assign
            filter-point = "all-rvs"
            tbl          = 'rvs-doc'
            join-tbl     = 'r-doc'
            fld          = 'host-code,obj-code,obj-type,rvs-code,status_,rvs-type,out-code,fact-date,shift-date,shift-name,shift-num'
            lab          = 'Фирма,Код_объекта,Тип_Объекта,Код_сверки,Статус_сверки,Тип_сверки,Код_накладной,Дата_факт,Дата_смены,Номер_смены,Порядок_смены'
            spr          = ',,,,,,,,,'
            dim          = '10'
            .
        do
            on stop undo, leave
            :
            run gbl/filter.w
                ( input parparentproc
                ,input filter-point
                ,input tbl
                ,input join-tbl
                ,input fld
                ,input lab
                ,input spr
                ,input dim
                ).
            run openbr in this-procedure .
        end .
    END.
ON CHOOSE OF b-sel IN FRAME d-all-r-docs
DO:
        if not available r-doc then do:     message       "Неправильный выбор документа сверки."       view-as alert-box .     return no-apply.   end.   else do:     assign       rvs-rec = recid (r-doc)     .   end.
  assign
    out-rec = recid( r-doc )
            .
        apply "go" to frame d-all-r-docs.
    END.
ON RETURN OF br-r-docs IN FRAME d-all-r-docs
OR mouse-select-dblclick of br-r-docs in frame d-all-r-docs
    do:
        apply "choose" to b-lkp in frame d-all-r-docs.
    end.
ON ROW-DISPLAY OF br-r-docs IN FRAME d-all-r-docs
DO:
    if   autorvs(recid(r-doc)) = "А"
       then
        do:
            do ii = 1 to 34:
                bcol[ii]:FGcolor  = 7.
            end.
        end.
    END.
ON VALUE-CHANGED OF br-r-docs IN FRAME d-all-r-docs
DO:
        define buffer buf_clients for ub.clients .
        if available r-doc then
        do:
            assign
                f-boss-name = ?
                f-agnt-name = ?
                f-wrkr-name = ?
                f-obj-name  = ?
                f-cre-name  = ?
                .
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  r-doc.creid
  ,output f-cre-name
  )  .
            find first buf_clients no-lock
                where buf_clients.obj-type = 'чел':U
                and buf_clients.obj-code = r-doc.boss
                no-error.
            if available buf_clients then
            do:
                assign
                    f-boss-name = buf_clients.obj-name
                    .
            end.
            find first buf_clients no-lock
                where buf_clients.obj-type = 'чел':U
                and buf_clients.obj-code = r-doc.agnt
                no-error.
            if available buf_clients then
            do:
                assign
                    f-agnt-name = buf_clients.obj-name
                    .
            end.
            find first buf_clients no-lock
                where buf_clients.obj-type = 'чел':U
                and buf_clients.obj-code = r-doc.wrkr
                no-error.
            if available buf_clients then
            do:
                assign
                    f-wrkr-name = buf_clients.obj-name
                    .
            end.
            find first buf_clients no-lock
                where buf_clients.obj-type = r-doc.obj-type
                and buf_clients.obj-code = r-doc.obj-code
                no-error.
            if available buf_clients then
            do:
                assign
                    f-obj-name = buf_clients.obj-name
                    .
            end.
            assign
                ed-notes = r-doc.ps
                .
            display
                ed-notes
                f-obj-name
                f-boss-name
                f-agnt-name
                f-wrkr-name
                f-cre-name
                with frame d-all-r-docs.
        end.
    END.
ON CHOOSE OF Btn_Copy IN FRAME d-all-r-docs
DO:
        if not available r-doc then
        do:
            message
                "Не выбрана сверка, из которой нужно сделать сменную."
                view-as alert-box.
            return no-apply.
        end.
        run proc-copy in this-procedure
            no-error.
        if error-status :error then
        do:
            return no-apply.
        end.
        run UI-on in this-procedure.
    END.
ON ENTRY OF ed-notes IN FRAME d-all-r-docs
DO:
        if not available r-doc then
        do:
            message
                "Неправильный выбор документа."
                view-as alert-box .
            return no-apply.
        end.
        assign
            rvs-rec = recid( r-doc )
            .
        if r-doc.status_ <> 'факт':U and substring (r-doc.PS, 1, 1) = "@" then
        do:
            message
                "Чтобы программа не могла заново переписать Ваше примечание, удалите знак @."
                view-as alert-box .
        end.
    END.
ON LEAVE OF ed-notes IN FRAME d-all-r-docs
DO:
        define buffer bf-rvs for ub.rvs-doc.
        do
            on stop  undo, return no-apply
            on error undo, return no-apply
            :
            find first bf-rvs exclusive-lock
                where recid (bf-rvs) = rvs-rec
                .
            assign
                bf-rvs.PS = input frame d-all-r-docs ed-notes
                .
        end.
    END.
ON RETURN OF ed-notes IN FRAME d-all-r-docs
OR mouse-select-dblclick of ed-notes in frame d-all-r-docs
    DO:
        apply "entry" to br-r-docs in frame d-all-r-docs.
        return no-apply.
    END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-all-r-docs:PARENT eq ?
    THEN FRAME d-all-r-docs:PARENT = ACTIVE-WINDOW.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-all-r-docs
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
on choose of b-help in frame d-all-r-docs
do:
  apply "help":u to frame d-all-r-docs .
end.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-all-r-docs:width - 0.3
                fh            = frame d-all-r-docs:first-child
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
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame d-all-r-docs :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-all-r-docs :height-chars)
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
    if frame d-all-r-docs :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-all-r-docs :height-chars)
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
            frame d-all-r-docs :height = v-frame-height
          .
          if frame d-all-r-docs :scrollable = true
          then do:
            assign
              frame d-all-r-docs :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-all-r-docs :scrollable = true
          then do:
            assign
              frame d-all-r-docs :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-all-r-docs :height = v-frame-height
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
      v-frame-height = frame d-all-r-docs :height
      v-frame-virtual-height = frame d-all-r-docs :virtual-height
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
      v-field-group-handle = frame d-all-r-docs :first-child
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
    do with frame d-all-r-docs
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-all-r-docs :scrollable = true
      then do:
        assign
          frame d-all-r-docs :virtual-height = frame d-all-r-docs :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-all-r-docs :height = frame d-all-r-docs :height + p-change-value
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
        frame d-all-r-docs :height = frame d-all-r-docs :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-all-r-docs :scrollable = true
      then do:
        assign
          frame d-all-r-docs :virtual-height = frame d-all-r-docs :virtual-height + p-change-value
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
          ,input  string(frame d-all-r-docs :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame d-all-r-docs :height)
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
    if frame d-all-r-docs :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-all-r-docs :width
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
    if frame d-all-r-docs :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-all-r-docs :width
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
            frame d-all-r-docs :width = v-frame-width
          .
          if frame d-all-r-docs :scrollable = true
          then do:
            assign
              frame d-all-r-docs :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-all-r-docs :scrollable = true
          then do:
            assign
              frame d-all-r-docs :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-all-r-docs :width = v-frame-width
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
      v-frame-width = frame d-all-r-docs :width
      v-frame-virtual-width = frame d-all-r-docs :virtual-width
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
      v-field-group-handle = frame d-all-r-docs :first-child
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
    do with frame d-all-r-docs
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-all-r-docs :scrollable = true
      then do:
        assign
          frame d-all-r-docs :virtual-width = frame d-all-r-docs :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-all-r-docs :width = v-frame-width + p-change-value
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
        frame d-all-r-docs :width = frame d-all-r-docs :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-all-r-docs :scrollable = true
      then do:
        assign
          frame d-all-r-docs :virtual-width = frame d-all-r-docs :virtual-width + p-change-value
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
          ,input  string(frame d-all-r-docs :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame d-all-r-docs :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-all-r-docs
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-all-r-docs :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-all-r-docs :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-all-r-docs :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-all-r-docs :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame d-all-r-docs
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
      v-row-delta = v-new-row - frame d-all-r-docs :height
      v-col-delta = v-new-col - frame d-all-r-docs :width
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
            - frame d-all-r-docs :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-all-r-docs :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-all-r-docs :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-all-r-docs :height-chars
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
      v-diasize-current-frame-width  = frame d-all-r-docs :width
      v-diasize-current-frame-height = frame d-all-r-docs :height
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
    do with frame d-all-r-docs
    :
      assign
        v-diasize-orig-frame-height = frame d-all-r-docs :height
        v-diasize-orig-frame-width  = frame d-all-r-docs :width
        v-diasize-browse-handle     = browse br-r-docs :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-all-r-docs :first-child
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
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame d-all-r-docs anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame d-all-r-docs. END.
  return no-apply.
end.
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame d-all-r-docs anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame d-all-r-docs. END.
  return no-apply.
end.
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame d-all-r-docs anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame d-all-r-docs. END.
  return no-apply.
end.
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame d-all-r-docs anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame d-all-r-docs. END.
  return no-apply.
end.
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-F7 of frame d-all-r-docs anywhere do:
  if b-close :sensitive then DO: apply "CHOOSE":U to b-close in frame d-all-r-docs. END.
  return no-apply.
end.
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-F8 of frame d-all-r-docs anywhere do:
  if b-open :sensitive then DO: apply "CHOOSE":U to b-open in frame d-all-r-docs. END.
  return no-apply.
end.
define variable vss-include-info29 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame d-all-r-docs anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame d-all-r-docs. END.
  return no-apply.
end.
define variable vss-include-info30 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame d-all-r-docs anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame d-all-r-docs. END.
  return no-apply.
end.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame d-all-r-docs:
    if p-filter-name > "" then do:
      assign
        frame d-all-r-docs:title
          = frame d-all-r-docs:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :tooltip = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :tooltip = ""
      .
    end.
  end.
end procedure.
def var sort-labelbr-r-docs   as character no-undo .
def var sort-clmnbr-r-docs    as handle    no-undo .
def var cur-clmnbr-r-docs     as handle    no-undo .
def var cur-clmn-locbr-r-docs as integer   no-undo .
def var re-querybr-r-docs     as logical   initial no no-undo .
on start-search, ctrl-o of br-r-docs in frame d-all-r-docs do:
   run sort-brbr-r-docs
     (input (if available r-doc
             then recid(r-doc)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-r-docs :
  define input parameter p-recid as recid no-undo .
  if re-querybr-r-docs = no then do:
    assign
       cur-clmnbr-r-docs = br-r-docs:current-column in frame d-all-r-docs
    .
    if sort-clmnbr-r-docs <> ? then sort-clmnbr-r-docs:column-fgcolor = 0.
    if cur-clmnbr-r-docs = sort-clmnbr-r-docs then do:
      assign
         sort-labelbr-r-docs = ""
         sort-clmnbr-r-docs = ?
      .
     end.
     else do:
       assign
         sort-labelbr-r-docs = cur-clmnbr-r-docs:label
         sort-clmnbr-r-docs  = cur-clmnbr-r-docs
         sort-clmnbr-r-docs:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-r-docs = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-r-docs:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-r-docs then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-r-docs = cur-clmn-locbr-r-docs + 1
    .
  end.
  case sort-labelbr-r-docs:
        when '*'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1mark-string&1, recid(r-doc)) ', chr(34) )     .     run OpenBr   . END.
        when ' Tип '  then DO:    assign       sort-column-name = "(substring (r-doc.rvs-type, 1, 9))"     .     run OpenBr   . END.
        when ' '  then DO:   assign       sort-column-name = substitute('dynamic-function(&1autorvs&1, recid(r-doc)) ', chr(34) )     .     run OpenBr   . END.
        when 'Стат'  then DO:    assign       sort-column-name = "r-doc.status_"     .     run OpenBr   . END.
        when 'Документ'  then DO:    assign       sort-column-name = "r-doc.rvs-code"     .     run OpenBr   . END.
        when 'Дата'  then DO:    assign       sort-column-name = "(substring ((string (r-doc.doc-date)), 1, 5))"     .     run OpenBr   . END.
        when 'Факт'  then DO:    assign       sort-column-name = "r-doc.fact-date"     .     run OpenBr   . END.
        when 'Время'  then DO:    assign       sort-column-name = "string(r-doc.fact-time,'hh:mm:ss')"     .     run OpenBr   . END.
        when 'Документ'  then DO:    assign       sort-column-name = "r-doc.out-code"     .     run OpenBr   . END.
        when 'Смена'  then DO:    assign       sort-column-name = "(substring ((string (r-doc.shift-date)), 1, 5))"     .     run OpenBr   . END.
        when '№'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1shift-name&1, recid( r-doc)) ', chr(34) )     .     run OpenBr   . END.
        when r-doc.state-measure-qnty:label in browse br-r-docs then DO:    assign       sort-column-name = "r-doc.state-measure-qnty"     .     run OpenBr   . END.
        when r-doc.measure-qnty:label in browse br-r-docs then DO:    assign       sort-column-name = "r-doc.measure-qnty"     .     run OpenBr   . END.
        when r-doc.state-brutto-qnty:label in browse br-r-docs then DO:    assign       sort-column-name = "r-doc.state-brutto-qnty"     .     run OpenBr   . END.
        when r-doc.brutto-qnty:label in browse br-r-docs then DO:    assign       sort-column-name = "r-doc.brutto-qnty"     .     run OpenBr   . END.
        when r-doc.system-qnty:label in browse br-r-docs then DO:    assign       sort-column-name = "r-doc.system-qnty"     .     run OpenBr   . END.
        when r-doc.system-cli-qnty:label in browse br-r-docs then DO:    assign       sort-column-name = "r-doc.system-cli-qnty"     .     run OpenBr   . END.
        when r-doc.system-cli-avrg-qnty:label in browse br-r-docs then DO:    assign       sort-column-name = "r-doc.system-cli-avrg-qnty"     .     run OpenBr   . END.
        when r-doc.measure-cli-qnty:label in browse br-r-docs then DO:    assign       sort-column-name = "r-doc.measure-cli-qnty"     .     run OpenBr   . END.
        when r-doc.state-measure-cli-qnty:label in browse br-r-docs then DO:    assign       sort-column-name = "r-doc.state-measure-cli-qnty"     .     run OpenBr   . END.
        when r-doc.brutto-cli-qnty:label in browse br-r-docs then DO:    assign       sort-column-name = "r-doc.brutto-cli-qnty"     .     run OpenBr   . END.
        when r-doc.state-brutto-cli-qnty:label in browse br-r-docs then DO:    assign       sort-column-name = "r-doc.state-brutto-cli-qnty"     .     run OpenBr   . END.
        when r-doc.meas-mh-qnty:label in browse br-r-docs then DO:    assign       sort-column-name = "r-doc.meas-mh-qnty"     .     run OpenBr   . END.
        when r-doc.state-mh-qnty:label in browse br-r-docs then DO:    assign       sort-column-name = "r-doc.state-mh-qnty"     .     run OpenBr   . END.
        when r-doc.meas-am-qnty:label in browse br-r-docs then DO:    assign       sort-column-name = "r-doc.meas-am-qnty"     .     run OpenBr   . END.
        when r-doc.state-am-qnty:label in browse br-r-docs then DO:    assign       sort-column-name = "r-doc.state-am-qnty"     .     run OpenBr   . END.
        when r-doc.meas-cf-qnty:label in browse br-r-docs then DO:    assign       sort-column-name = "r-doc.meas-cf-qnty"     .     run OpenBr   . END.
        when r-doc.state-cf-qnty:label in browse br-r-docs then DO:    assign       sort-column-name = "r-doc.state-cf-qnty"     .     run OpenBr   . END.
        when r-doc.level-petrol:label in browse br-r-docs then DO:    assign       sort-column-name = "r-doc.level-petrol"     .     run OpenBr   . END.
        when r-doc.state-level-petrol:label in browse br-r-docs then DO:    assign       sort-column-name = "r-doc.state-level-petrol"     .     run OpenBr   . END.
        when r-doc.level-total:label in browse br-r-docs then DO:    assign       sort-column-name = "r-doc.level-total"     .     run OpenBr   . END.
        when r-doc.state-level-total:label in browse br-r-docs then DO:    assign       sort-column-name = "r-doc.state-level-total"     .     run OpenBr   . END.
        when r-doc.level-water:label in browse br-r-docs then DO:    assign       sort-column-name = "r-doc.level-water"     .     run OpenBr   . END.
        when r-doc.state-level-water:label in browse br-r-docs then DO:    assign       sort-column-name = "r-doc.state-level-water"     .     run OpenBr   . END.
        when 'тв'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1get-input-type&1, recid(r-doc)) ', chr(34) )     .     run OpenBr   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr.
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr-r-docs') then do:
          run mv-brw-defaultbr-r-docs.
        end.
      if sort-labelbr-r-docs <> "" then do:
        assign
          cur-clmnbr-r-docs:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-r-docs = ?
      .
    end.
  end case.
    if cur-clmn-locbr-r-docs <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbr-r-docs') then do:
        run ch-clmnbr-r-docs in this-procedure (cur-clmn-locbr-r-docs).
      end.
    end.
  if p-recid <> ? then do:
    reposition br-r-docs to recid p-recid no-error.
    apply "value-changed" to br-r-docs in frame d-all-r-docs.
  end.
  apply "entry" to br-r-docs in frame d-all-r-docs.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-r-docs:
if cur-clmnbr-r-docs = ? then do:
   run OpenBr.
end.
else do:
   assign re-querybr-r-docs = yes.
   run sort-brbr-r-docs
     (input (if available r-doc
             then recid(r-doc)
             else ?
            )
     ).
   assign re-querybr-r-docs = no.
end.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-r-docs as INT EXTENT 34 no-undo.
DEF VAR varmvibr-r-docs       as INT no-undo.
DEF VAR varmvjbr-r-docs       as INT no-undo.
DEF VAR varmvkbr-r-docs       as INT no-undo.
DEF VAR varmvlbr-r-docs       as INT no-undo.
DEF VAR move-elementbr-r-docs as INT no-undo.
def var jjbr-r-docs           as int no-undo.
do varmvibr-r-docs = 1 to EXTENT(cur-clmn-numbr-r-docs):
  ASSIGN cur-clmn-numbr-r-docs[varmvibr-r-docs] = varmvibr-r-docs.
END.
RUN start-mv-clmnbr-r-docs.
PROCEDURE start-mv-clmnbr-r-docs:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-r-docs do:
  RUN re-move-clmnbr-r-docs ( 4, 34).
END.
ON ctrl-cursor-left OF BROWSE br-r-docs do:
  RUN re-move-clmnbr-r-docs (34, 4).
END.
PROCEDURE re-move-clmnbr-r-docs:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-r-docs = 1 TO EXTENT(cur-clmn-numbr-r-docs):
    if cur-clmn-numbr-r-docs[varmvibr-r-docs] = source-column THEN cur-clmn-numbr-r-docs[varmvibr-r-docs] = -1.
  END.
  if br-r-docs:MOVE-COLUMN(source-column, target-column) IN FRAME d-all-r-docs then.
  if source-column > target-column THEN
  DO varmvjbr-r-docs = source-column - 1 to target-column BY -1:
    DO varmvibr-r-docs = 1 TO EXTENT(cur-clmn-numbr-r-docs):
        if cur-clmn-numbr-r-docs[varmvibr-r-docs] = varmvjbr-r-docs THEN DO:
          cur-clmn-numbr-r-docs[varmvibr-r-docs] = cur-clmn-numbr-r-docs[varmvibr-r-docs] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-r-docs = source-column + 1 to target-column:
    DO varmvibr-r-docs = 1 TO EXTENT(cur-clmn-numbr-r-docs):
      if cur-clmn-numbr-r-docs[varmvibr-r-docs] = varmvjbr-r-docs THEN DO:
        cur-clmn-numbr-r-docs[varmvibr-r-docs] = cur-clmn-numbr-r-docs[varmvibr-r-docs] - 1.
      END.
    END.
  END.
  DO varmvibr-r-docs = 1 TO EXTENT(cur-clmn-numbr-r-docs):
    if cur-clmn-numbr-r-docs[varmvibr-r-docs] = -1 THEN cur-clmn-numbr-r-docs[varmvibr-r-docs] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-r-docs:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 4 then do:
    return .
  end.
  DO varmvibr-r-docs = 1 TO EXTENT(cur-clmn-numbr-r-docs):
    if cur-clmn-numbr-r-docs[varmvibr-r-docs] = cur-clmn-loc THEN move-elementbr-r-docs = varmvibr-r-docs.
  END.
  RUN re-move-clmnbr-r-docs (cur-clmn-loc, 4).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-r-docs:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-r-docs = 4 to EXTENT(cur-clmn-numbr-r-docs):
    RUN re-move-clmnbr-r-docs (cur-clmn-numbr-r-docs[varmvlbr-r-docs], varmvlbr-r-docs).
  END.
  RUN start-mv-clmnbr-r-docs.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
    do ii = 1 to 34:
        bcol[ii] = br-r-docs:get-browse-column(ii).
    end.
    assign
        filter-point = "all-rvs":U
        .
    run UI-on in this-procedure .
    WAIT-FOR GO OF FRAME d-all-r-docs focus br-r-docs.
END.
RUN disable_UI in this-procedure .
PROCEDURE delete-doc-inv :
define input parameter pardoc-rec as recid no-undo.
    do
        on error  undo, return error substitute( "&1 (delete-doc-inv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        on stop   undo, return error substitute( "&1 (delete-doc-inv). stop", vss-workfile )
        on endkey undo, return error substitute( "&1 (delete-doc-inv). endkey", vss-workfile )
        :
        define variable varchg-inv    as logical   no-undo.
        define variable v-docs-list   as character no-undo .
        define variable v-ind         as integer   no-undo .
        define variable v-num-entries as integer   no-undo .
        define variable v-doc-code    as character no-undo .
        define variable v-chip-num    as integer   no-undo .
        define variable v-user-action as character no-undo .
        define variable v-printed     as logical   no-undo .
        define buffer buf_parts       for ub.parts .
        define buffer buf-inv_trn-doc for ub.trn-doc .
        define buffer buf-add_trn-doc for ub.trn-doc .
        find first buf-inv_trn-doc exclusive-lock
            where recid( buf-inv_trn-doc ) = pardoc-rec
            .
        assign
            v-docs-list = buf-inv_trn-doc.doc-code
            .
        for each buf-add_trn-doc
            where buf-add_trn-doc.out-code = buf-inv_trn-doc.doc-code
            on error undo, return error return-value
            :
            assign
                v-docs-list = buf-add_trn-doc.doc-code + ",":U + v-docs-list
                .
        end.
        assign
            v-num-entries = num-entries( v-docs-list )
            .
        do v-ind = 1 to v-num-entries
            on error undo, return error return-value
            :
            assign
                v-doc-code = entry( v-ind, v-docs-list )
                .
            find first buf-add_trn-doc exclusive-lock
                where buf-add_trn-doc.doc-code = v-doc-code
                .
            assign
                buf-add_trn-doc.status_ = 'разрешен':U
                buf-add_trn-doc.flag_   = yes
                .
            run str/trn-stat.p
                ( input parparentproc
                , input this-procedure
                ,input '<открытие документа>':U
                ,input buf-add_trn-doc.doc-code
                ,input ?
                ,input v-cntxt-db-num
                ,input ?
                ,input ?
                ,input ?
                ,input ?
                ,input yes
                ,output varchg-inv
                ,output table gds-list
                ) no-error.
            if error-status :error then
            do:
                undo, return error return-value.
            end.
            release buf-add_trn-doc.
            find first buf-add_trn-doc exclusive-lock
                where buf-add_trn-doc.doc-code = v-doc-code
                .
            run str/trn-stat.p
                ( input parparentproc
                , input this-procedure
                ,input '<открытие документа>':U
                ,input buf-add_trn-doc.doc-code
                ,input ?
                ,input v-cntxt-db-num
                ,input ?
                ,input ?
                ,input ?
                ,input ?
                ,input yes
                ,output varchg-inv
                ,output table gds-list
                ) no-error.
            if error-status :error then
            do:
                undo, return error return-value.
            end.
            case buf-add_trn-doc.doc-type :
                when 'при':U then
                    do:
define variable vss-include-info33 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_preparation':U
    ,input  'object':U
    ,input  buf-add_trn-doc.host-code
    ,input  buf-add_trn-doc.obj-type
    ,input  buf-add_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
                    end.
                when 'рас':U then
                    do:
define variable vss-include-info34 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_preparation':U
    ,input  'object':U
    ,input  buf-add_trn-doc.host-code
    ,input  buf-add_trn-doc.obj-type
    ,input  buf-add_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
                    end.
                when 'спи':U then
                    do:
define variable vss-include-info35 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_write-off_preparation':U
    ,input  'object':U
    ,input  buf-add_trn-doc.host-code
    ,input  buf-add_trn-doc.obj-type
    ,input  buf-add_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
                    end.
                when 'инв':U then
                    do:
define variable vss-include-info36 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_inventory_delete':U
    ,input  'object':U
    ,input  buf-add_trn-doc.host-code
    ,input  buf-add_trn-doc.obj-type
    ,input  buf-add_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
                    end.
                when 'возврат':U then
                    do:
define variable vss-include-info37 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_return_preparation':U
    ,input  'object':U
    ,input  buf-add_trn-doc.host-code
    ,input  buf-add_trn-doc.obj-type
    ,input  buf-add_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
                    end.
                otherwise
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Неизвестный тип документа" skip
                        "Тип документа" buf-add_trn-doc.doc-type skip
                        "Код документа" buf-add_trn-doc.doc-code skip
                        view-as alert-box error .
                    undo, return no-apply .
                end.
            end case .
            if varlog <> yes
                then
            do:
                undo, return error.
            end.
            run waitfram-show in this-procedure ( input "Удаление документа № " + buf-add_trn-doc.doc-code + ". Ждите..." ).
            if search ("del-doc.err") <> ? then
            do:
                os-delete "del-doc.err".
            end.
            run str/del-doc.p
                ( input  parparentproc
                , input  buf-add_trn-doc.doc-code
                , input  v-cntxt-db-num
                , input  "del-doc.err":U
                , input  ?
                , input  ?
                , input  v-cntxt-userid
                , input  0
                , input  ?
                , output v-chip-num
                ) no-error.
            if error-status:error then
            do:
                run waitfram-hide in this-procedure .
                message
                    vss-workfile vss-revision vss-description skip
                    "Ошибка при удалении документа." skip
                    return-value
                    view-as alert-box error.
                if search ("del-doc.err") <> ? then
                do:
                    run gbl/prnfilen.w
                        (input  "Ошибки при удалении документа"
                        ,input  0
                        ,input  "del-doc.err"
                        ,input  7
                        ,output v-user-action
                        ,output v-printed
                        ).
                end.
                undo, return error.
            end.
            rvsinvstrObj = new rvsinvstr ().
            rvsinvstrObj:DeleteDB(r-doc.rvs-code, r-doc.obj-type, r-doc.obj-code).
            run waitfram-hide in this-procedure .
        end.
    end.
end procedure.
PROCEDURE disable_UI :
  HIDE FRAME d-all-r-docs.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY ed-notes f-boss-name f-obj-name f-agnt-name f-wrkr-name f-cre-name
      WITH FRAME d-all-r-docs.
  ENABLE b-quit b-mark b-sel b-add b-lkp b-chg b-del b-close b-open b-hist
         b-help Btn_Copy b-inv b-sch b-print br-r-docs ed-notes
      WITH FRAME d-all-r-docs.
  VIEW FRAME d-all-r-docs.
  OPEN QUERY br-r-docs FOR EACH r-doc .
END PROCEDURE.
PROCEDURE local-mark :
if not available r-doc then
    do:
        message "Неправильный выбор строки.".
        return .
    end.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid39 as character no-undo .
define variable v-num-entry39 as integer   no-undo .
assign
  v-str-recid39 = trim( string( recid( r-doc ) , "->>>>>>>>>>>9":U ) )
  v-num-entry39 = lookup( v-str-recid39 , del-list )
.
if v-num-entry39 > 0 then do:
  assign
    entry( v-num-entry39, del-list ) = "":U
    del-list = trim( replace( del-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    del-list = del-list + ( if del-list = "":U then "":U else chr(44) ) + v-str-recid39
  .
end.
    br-r-docs:refresh() in frame d-all-r-docs .
END PROCEDURE.
PROCEDURE Openbr :
define variable sort-column-phrase as character no-undo .
    define variable l-query-was-opened as logical   no-undo .
    define buffer bf_clients for ub.clients.
    run waitfram-show in this-procedure
        (input "Ждите..."
        ).
    case sort-column-name :
        when "" then
            do:
                assign
                    sort-column-phrase = ""
                    .
            end.
        otherwise
        do:
            assign
                sort-column-phrase = "by " + sort-column-name
                .
        end.
    end case.
    assign
        varobj-type  = v-cntxt-obj-type
        varobj-code  = v-cntxt-obj-code
        varhost-code = v-cntxt-host-code-obj
        vartest-asi  = 'проверка':U
    .
    find first bf_clients  where bf_clients.obj-type = v-cntxt-obj-type and
        bf_clients.obj-code = v-cntxt-obj-code no-lock.
    case parlist-mode:
        when 'работа':U then
            do:
                assign
                    frame d-all-r-docs:title = "ДОКУМЕНТЫ СВЕРКИ".
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-41  as logical   no-undo .
define variable  l-filter-open-41    as logical   .
define variable  flt-rec-41       as recid     no-undo .
define variable  filter-name-41      as character no-undo .
define variable  where-phrase-41     as character no-undo .
define variable  sort-phrase-41      as character no-undo .
define variable  where-phrase-rus-41 as character no-undo .
define variable  sort-phrase-rus-41  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-41
  ,output filter-name-41
  ,output where-phrase-41
  ,output sort-phrase-41
  ,output where-phrase-rus-41
  ,output sort-phrase-rus-41
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-41
      ) no-error .
  assign
    l-filter-open-41 = false
  .
  if flt-rec-41 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-41 as character no-undo .
    define variable  parameter-3-41 as character no-undo .
    define variable  parameter-4-41 as character no-undo .
    define variable  parameter-5-41 as character no-undo .
    define variable  parameter-6-41 as character no-undo .
    define variable  parameter-7-41 as character no-undo .
      assign
      parameter-3-41 =
                              "FOR EACH r-doc"
      parameter-4-41 =
        (
          if (" r-doc.rvs-type <> vartest-asi " + " " + where-phrase-41) <> ""
          then  substitute( '  r-doc.rvs-type <> &1&2&1 ' , chr(34) , vartest-asi )  + " " + where-phrase-41
          else "true"
        )
      parameter-5-41 = (" " + "" + " " + "")
      parameter-6-41 = if sort-phrase-41 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-41
        )
      parameter-7-41 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-41 =
          (" r-doc.rvs-type <> vartest-asi " + " " + where-phrase-41 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-r-docs:handle
                          ,input parameter-3-41
                          ,input parameter-4-41
                          ,input parameter-5-41
                          ,input parameter-6-41
                          ,input parameter-7-41
                          )
      .
      assign
        l-filter-open-41 = true
      .
    end.
    if l-filter-open-41 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-41 = false then do:
    open query br-r-docs for each r-doc
      where  r-doc.rvs-type <> vartest-asi
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
            end.
        when 'фирма':U then
            do:
                assign
                    frame d-all-r-docs:title = "ДОКУМЕНТЫ СВЕРКИ Фирма : " + string(varhost-code).
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-43  as logical   no-undo .
define variable  l-filter-open-43    as logical   .
define variable  flt-rec-43       as recid     no-undo .
define variable  filter-name-43      as character no-undo .
define variable  where-phrase-43     as character no-undo .
define variable  sort-phrase-43      as character no-undo .
define variable  where-phrase-rus-43 as character no-undo .
define variable  sort-phrase-rus-43  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-43
  ,output filter-name-43
  ,output where-phrase-43
  ,output sort-phrase-43
  ,output where-phrase-rus-43
  ,output sort-phrase-rus-43
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-43
      ) no-error .
  assign
    l-filter-open-43 = false
  .
  if flt-rec-43 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-43 as character no-undo .
    define variable  parameter-3-43 as character no-undo .
    define variable  parameter-4-43 as character no-undo .
    define variable  parameter-5-43 as character no-undo .
    define variable  parameter-6-43 as character no-undo .
    define variable  parameter-7-43 as character no-undo .
      assign
      parameter-3-43 =
                              "FOR EACH r-doc"
      parameter-4-43 =
        (
          if (" r-doc.host-code = varhost-code and r-doc.rvs-type <> vartest-asi " + " " + where-phrase-43) <> ""
          then  substitute( '  r-doc.host-code = &2 and r-doc.rvs-type <> &1&3&1 ' , chr(34) , varhost-code , vartest-asi )  + " " + where-phrase-43
          else "true"
        )
      parameter-5-43 = (" " + "" + " " + "")
      parameter-6-43 = if sort-phrase-43 = ''
                           then
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-43
        )
      parameter-7-43 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-43 =
          (" r-doc.host-code = varhost-code and r-doc.rvs-type <> vartest-asi " + " " + where-phrase-43 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-r-docs:handle
                          ,input parameter-3-43
                          ,input parameter-4-43
                          ,input parameter-5-43
                          ,input parameter-6-43
                          ,input parameter-7-43
                          )
      .
      assign
        l-filter-open-43 = true
      .
    end.
    if l-filter-open-43 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-43 = false then do:
    open query br-r-docs for each r-doc
      where  r-doc.host-code = varhost-code and r-doc.rvs-type <> vartest-asi
       use-index host-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
            end.
        when 'объект':U then
            do:
                assign
                    frame d-all-r-docs:title = "ДОКУМЕНТЫ СВЕРКИ Объект : " + varobj-type + " " + string (varobj-code).
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-45  as logical   no-undo .
define variable  l-filter-open-45    as logical   .
define variable  flt-rec-45       as recid     no-undo .
define variable  filter-name-45      as character no-undo .
define variable  where-phrase-45     as character no-undo .
define variable  sort-phrase-45      as character no-undo .
define variable  where-phrase-rus-45 as character no-undo .
define variable  sort-phrase-rus-45  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-45
  ,output filter-name-45
  ,output where-phrase-45
  ,output sort-phrase-45
  ,output where-phrase-rus-45
  ,output sort-phrase-rus-45
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-45
      ) no-error .
  assign
    l-filter-open-45 = false
  .
  if flt-rec-45 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-45 as character no-undo .
    define variable  parameter-3-45 as character no-undo .
    define variable  parameter-4-45 as character no-undo .
    define variable  parameter-5-45 as character no-undo .
    define variable  parameter-6-45 as character no-undo .
    define variable  parameter-7-45 as character no-undo .
      assign
      parameter-3-45 =
                              "FOR EACH r-doc"
      parameter-4-45 =
        (
          if (" r-doc.obj-type = varobj-type and   r-doc.obj-code = varobj-code  and r-doc.rvs-type <> vartest-asi " + " " + where-phrase-45) <> ""
          then  substitute( '                                      r-doc.obj-type =  &1&2&1 and                                     r-doc.obj-code =  &3 and                                       r-doc.rvs-type <> &1&4&1                                     ' , chr(34) , varobj-type , varobj-code , vartest-asi  )  + " " + where-phrase-45
          else "true"
        )
      parameter-5-45 = (" " + "" + " " + "")
      parameter-6-45 = if sort-phrase-45 = ''
                           then
        (
        " " + "use-index stat-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "use-index stat-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-45
        )
      parameter-7-45 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-45 =
          (" r-doc.obj-type = varobj-type and   r-doc.obj-code = varobj-code  and r-doc.rvs-type <> vartest-asi " + " " + where-phrase-45 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-r-docs:handle
                          ,input parameter-3-45
                          ,input parameter-4-45
                          ,input parameter-5-45
                          ,input parameter-6-45
                          ,input parameter-7-45
                          )
      .
      assign
        l-filter-open-45 = true
      .
    end.
    if l-filter-open-45 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-45 = false then do:
    open query br-r-docs for each r-doc
      where  r-doc.obj-type = varobj-type and   r-doc.obj-code = varobj-code  and r-doc.rvs-type <> vartest-asi
      use-index stat-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
                if v-cntxt-db-num = bf_clients.db-num then
                    enable b-add b-chg b-del b-close b-open b-inv btn_copy with frame d-all-r-docs.
            end.
        when 'статус':U then
            do:
                assign
                    varstatus_ = parstatus.
                assign
                    frame d-all-r-docs:title = "Объект : " + varobj-type + " " + string (varobj-code) + "  Статус : " + varstatus_.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-47  as logical   no-undo .
define variable  l-filter-open-47    as logical   .
define variable  flt-rec-47       as recid     no-undo .
define variable  filter-name-47      as character no-undo .
define variable  where-phrase-47     as character no-undo .
define variable  sort-phrase-47      as character no-undo .
define variable  where-phrase-rus-47 as character no-undo .
define variable  sort-phrase-rus-47  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-47
  ,output filter-name-47
  ,output where-phrase-47
  ,output sort-phrase-47
  ,output where-phrase-rus-47
  ,output sort-phrase-rus-47
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-47
      ) no-error .
  assign
    l-filter-open-47 = false
  .
  if flt-rec-47 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-47 as character no-undo .
    define variable  parameter-3-47 as character no-undo .
    define variable  parameter-4-47 as character no-undo .
    define variable  parameter-5-47 as character no-undo .
    define variable  parameter-6-47 as character no-undo .
    define variable  parameter-7-47 as character no-undo .
      assign
      parameter-3-47 =
                              "FOR EACH r-doc"
      parameter-4-47 =
        (
          if ("r-doc.obj-type = varobj-type and
                                r-doc.obj-code = varobj-code and
                                r-doc.status_  = varstatus_ and
                                r-doc.rvs-type <> vartest-asi     " + " " + where-phrase-47) <> ""
          then  substitute( '                                      r-doc.obj-type =  &1&2&1 and                                     r-doc.obj-code =  &3  and                                      r-doc.status_  =  &1&4&1 and                                     r-doc.rvs-type <> &1&5&1                                      ' , chr(34) , varobj-type , varobj-code , varstatus_ , vartest-asi )  + " " + where-phrase-47
          else "true"
        )
      parameter-5-47 = (" " + "" + " " + "")
      parameter-6-47 = if sort-phrase-47 = ''
                           then
        (
        " " + "use-index stat-date" +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "use-index stat-date" +
          " " + sort-column-phrase +
        " " + sort-phrase-47
        )
      parameter-7-47 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-47 =
          ("r-doc.obj-type = varobj-type and
                                r-doc.obj-code = varobj-code and
                                r-doc.status_  = varstatus_ and
                                r-doc.rvs-type <> vartest-asi     " + " " + where-phrase-47 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-r-docs:handle
                          ,input parameter-3-47
                          ,input parameter-4-47
                          ,input parameter-5-47
                          ,input parameter-6-47
                          ,input parameter-7-47
                          )
      .
      assign
        l-filter-open-47 = true
      .
    end.
    if l-filter-open-47 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-47 = false then do:
    open query br-r-docs for each r-doc
      where r-doc.obj-type = varobj-type and
                                r-doc.obj-code = varobj-code and
                                r-doc.status_  = varstatus_ and
                                r-doc.rvs-type <> vartest-asi
      use-index stat-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
                if v-cntxt-db-num = bf_clients.db-num and
                    parstatus <> 'факт':U            then
                    enable b-add b-chg b-del b-close b-open b-inv btn_copy with frame d-all-r-docs.
            end.
        when "choose-control" then
            do :
                assign
                    frame d-all-r-docs:title = "ДОКУМЕНТЫ СВЕРКИ Объект : " + varobj-type + " " + string (varobj-code) + "  Статус : факт    Тип: контроль".
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-49  as logical   no-undo .
define variable  l-filter-open-49    as logical   .
define variable  flt-rec-49       as recid     no-undo .
define variable  filter-name-49      as character no-undo .
define variable  where-phrase-49     as character no-undo .
define variable  sort-phrase-49      as character no-undo .
define variable  where-phrase-rus-49 as character no-undo .
define variable  sort-phrase-rus-49  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-49
  ,output filter-name-49
  ,output where-phrase-49
  ,output sort-phrase-49
  ,output where-phrase-rus-49
  ,output sort-phrase-rus-49
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-49
      ) no-error .
  assign
    l-filter-open-49 = false
  .
  if flt-rec-49 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-49 as character no-undo .
    define variable  parameter-3-49 as character no-undo .
    define variable  parameter-4-49 as character no-undo .
    define variable  parameter-5-49 as character no-undo .
    define variable  parameter-6-49 as character no-undo .
    define variable  parameter-7-49 as character no-undo .
      assign
      parameter-3-49 =
                              "FOR EACH r-doc"
      parameter-4-49 =
        (
          if ("r-doc.obj-type = varobj-type and
                                r-doc.obj-code = varobj-code and
                                r-doc.status_  = 'факт':U     and
                                r-doc.rvs-type = 'контроль':U " + " " + where-phrase-49) <> ""
          then  substitute( '                                      r-doc.obj-type =  &1&2&1 and                                     r-doc.obj-code =  &3  and                                      r-doc.status_  =  &1&4&1                                      r-doc.rvs-type =  &1&5&1                                      ' , chr(34) , varobj-type , varobj-code , 'факт':U, 'контроль':U )  + " " + where-phrase-49
          else "true"
        )
      parameter-5-49 = (" " + "" + " " + "")
      parameter-6-49 = if sort-phrase-49 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-49
        )
      parameter-7-49 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-49 =
          ("r-doc.obj-type = varobj-type and
                                r-doc.obj-code = varobj-code and
                                r-doc.status_  = 'факт':U     and
                                r-doc.rvs-type = 'контроль':U " + " " + where-phrase-49 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-r-docs:handle
                          ,input parameter-3-49
                          ,input parameter-4-49
                          ,input parameter-5-49
                          ,input parameter-6-49
                          ,input parameter-7-49
                          )
      .
      assign
        l-filter-open-49 = true
      .
    end.
    if l-filter-open-49 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-49 = false then do:
    open query br-r-docs for each r-doc
      where r-doc.obj-type = varobj-type and
                                r-doc.obj-code = varobj-code and
                                r-doc.status_  = 'факт':U     and
                                r-doc.rvs-type = 'контроль':U
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
                enable b-sel with frame d-all-r-docs.
            end.
    end case.
    apply "entry" to br-r-docs in frame d-all-r-docs.
    if rvs-rec <> ? then
    do:
        reposition br-r-docs to recid rvs-rec no-error.
    end.
    if available r-doc then
    do:
  apply "value-changed" to br-r-docs in frame d-all-r-docs.
    end.
    run waitfram-hide in this-procedure .
END PROCEDURE.
PROCEDURE proc-copy :
define variable v-str as character no-undo.
    define variable jj    as integer   no-undo.
    do
        on error   undo, return error
        on end-key undo, return error
        on stop    undo, return error
        :
        if not available r-doc then
        do:
            message "Не выбрана сверка, из которой нужно сделать сменную." view-as alert-box.
            return error.
        end.
        run str/ctrc2sht.p
            ( input parparentproc
            ,input recid( r-doc )
            ) no-error.
        if error-status :error then
        do:
            assign
                v-str = "":U.
            do jj = 1 to error-status :num-messages :
                assign
                    v-str = v-str + ( if v-str = "":U then "":U else chr(10) ) + error-status :get-message( jj ).
            end.
            assign
                v-str = v-str + ( if v-str = "":U then "":U else chr(10) ) + return-value.
            message
                "Ошибка создания сверки." skip
                v-str
                view-as alert-box error title " О Ш И Б К А ! ! ! ".
            for each tt-susp-chk:
                find first ub.susp-chk exclusive-lock where ub.susp-chk.doc-code = tt-susp-chk.doc-code no-error .
                if not available (ub.susp-chk) then
                do:
                    create ub.susp-chk .
                    buffer-copy tt-susp-chk to ub.susp-chk .
                end.
                else do:
                    ub.susp-chk.reason-name = tt-susp-chk.reason-name .
                    ub.susp-chk.link-chk = tt-susp-chk.link-chk .
                end.
            end.
            return error.
        end.
    end.
END PROCEDURE.
PROCEDURE proc-del :
define variable del-rec   as recid   no-undo.
    define variable unrv-qnty as decimal no-undo.
    define variable varfind   as logical no-undo.
    define buffer bf-prev_rvs-doc  for ub.rvs-doc.
    define buffer bf_trn-doc       for ub.trn-doc.
    define buffer bf_doc-line      for ub.doc-line.
    define buffer bf_goods         for ub.goods.
    define buffer bf_rvs-line      for ub.rvs-line.
    define buffer bf-prev_rvs-line for ub.rvs-line.
    do
        on error   undo, return error
        on end-key undo, return error
        on stop    undo, return error
        :
        if r-doc.status_ <> 'новый':U
            and r-doc.status_ <> 'факт':U
            then
        do:
            message
                "Документ в данном статусе не может быть удален."
                view-as alert-box.
            return error   "Документ сверки с типом 'смена' в данном статусе не может быть удален" .
        end.
        if r-doc.status_ = 'факт':U then
        do:
            if r-doc.rvs-type = 'смена':U then
            do:
                message
                    "Документ сверки с типом 'смена' в данном статусе не может быть удален"
                    view-as alert-box.
                return error   "Документ сверки с типом 'смена' в данном статусе не может быть удален" .
            end.
            else
            do:
                if r-doc.rvs-type <> 'контроль':U then
                do:
                    message
                        "Закрытый документ сверки с типом, отличным от 'контроль', не может быть удален"
                        view-as alert-box.
                    return error "Закрытый документ сверки с типом, отличным от 'контроль', не может быть удален" .
                end.
                else
                do:
                    case r-doc.rvs-type :
                        when 'контроль':U then
                            do:
define variable vss-include-info50 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-control_del-fact':U
    ,input  'object':U
    ,input  r-doc.host-code
    ,input  r-doc.obj-type
    ,input  r-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
                            end.
                        otherwise
                        do:
                            message
                                vss-workfile vss-revision vss-description skip
                                "Неизвестный тип документа сверки" skip
                                "Тип документа сверки" r-doc.rvs-type skip
                                "Код документа сверки" r-doc.rvs-code skip
                                view-as alert-box error .
                            undo, return no-apply .
                        end.
                    end case .
                    if varlog <> yes then
                    do:
                        return error.
                    end.
                    for each bf_rvs-line no-lock
                        where bf_rvs-line.rvs-code = r-doc.rvs-code
                        on error undo, return error
                        :
                        assign
                            varfind = no
                            .
                        for each bf-prev_rvs-doc no-lock
                            where bf-prev_rvs-doc.obj-type   = r-doc.obj-type
                            and bf-prev_rvs-doc.obj-code   = r-doc.obj-code
                            and bf-prev_rvs-doc.fact-order < r-doc.fact-order
                            ,first bf-prev_rvs-line no-lock
                            where bf-prev_rvs-line.rvs-code = bf-prev_rvs-doc.rvs-code
                            and bf-prev_rvs-line.gds-code = bf_rvs-line.gds-code
                            on error undo, return error
                            :
                            assign
                                varfind = yes.
                            leave.
                        end.
                        if varfind <> yes then
                        do:
                            find first bf_goods no-lock
                                where bf_goods.gds-code = bf_rvs-line.gds-code
                                .
                            find first bf_doc-line no-lock
                                where bf_doc-line.obj-type  = r-doc.obj-type
                                and bf_doc-line.obj-code  = r-doc.obj-code
                                and bf_doc-line.artic     = bf_goods.artic
                                and bf_doc-line.prod-type = bf_goods.prod-type
                                and bf_doc-line.prod-code = bf_goods.prod-code
                                no-error.
                            if available bf_doc-line then
                            do:
                                message
                                    "Нельзя удалить сверку, являющуюся первой контрольной для товара."
                                    "На объекте есть складские документы по этому товару. Номер документа " bf_doc-line.doc-code
                                    " Товар " bf_doc-line.artic " " bf_doc-line.prod-type " " bf_doc-line.prod-code
                                    view-as alert-box.
                                return error substitute (      "Нельзя удалить сверку, являющуюся первой контрольной для товара.
                  На объекте есть складские документы по этому товару. Номер документа  &1 
                  Товар &2&3&4 " , bf_doc-line.doc-code , bf_doc-line.artic , bf_doc-line.prod-type, bf_doc-line.prod-code).
                            end.
                        end.
                        find first bf_trn-doc no-lock where bf_trn-doc.out-code = r-doc.rvs-code no-error.
                        if available bf_trn-doc then
                        do:
                            message "К сверке есть привязанные складские документы. Удалить нельзя."
                                "Номер документа " bf_trn-doc.doc-code " ."
                                view-as alert-box.
                            return error "К сверке есть привязанные складские документы. Удалить нельзя." .
                        end.
                    end.
                end.
            end.
        end.
        assign
            varlog = no.
        message
            "Удалить документ сверки №" r-doc.rvs-code "?" skip
            "   Вы уверены ?"
            view-as alert-box question buttons OK-Cancel update varlog.
        assign
            rvs-rec = recid( r-doc )
            .
        if not varlog then
        do:
            find first r-doc no-lock
                where recid (r-doc) = rvs-rec
                .
            return no-apply.
        end.
        case r-doc.rvs-type
            :
            when 'перед_док':U
            or
            when 'после_док':U
            then
                do:
define variable vss-include-info51 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-on-doc_deletion':U
    ,input  'object':U
    ,input  r-doc.host-code
    ,input  r-doc.obj-type
    ,input  r-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
                end.
            when 'смена':U then
                do:
define variable vss-include-info52 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-shift_deletion':U
    ,input  'object':U
    ,input  r-doc.host-code
    ,input  r-doc.obj-type
    ,input  r-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
                end.
            when 'контроль':U then
                do:
define variable vss-include-info53 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-control_deletion':U
    ,input  'object':U
    ,input  r-doc.host-code
    ,input  r-doc.obj-type
    ,input  r-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
                end.
            otherwise
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Неизвестный тип документа сверки" skip
                    "Тип документа сверки" r-doc.rvs-type skip
                    "Код документа сверки" r-doc.rvs-code skip
                    view-as alert-box error .
                undo, return no-apply .
            end.
        end case .
        if not varlog then
        do:
            find first r-doc no-lock
                where recid (r-doc) = rvs-rec
                .
            return no-apply.
        end.
        run waitfram-show in this-procedure
            ( input "Удаление документа сверки № " + r-doc.rvs-code + ". Ждите..."
            ).
        assign
            br-handle = br-r-docs :handle in frame d-all-r-docs
            del-rec   = recid( r-doc )
            .
        if valid-handle( br-handle ) then
        do:
            assign
                varlog = br-handle :select-next-row( )
                .
            if varlog <> true then
            do:
                assign
                    varlog = br-handle :select-prev-row( )
                    .
            end.
            if varlog = true then
            do:
                assign
                    rvs-rec = recid( r-doc )
                    .
            end.
        end.
        del-doc:
        do transaction
            on stop    undo del-doc, retry del-doc
            on error   undo del-doc, retry del-doc
            on end-key undo del-doc, retry del-doc
            :
            if retry then
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    substitute("Ошибка при удалении сверки.") skip
                    error-status :get-message(1) skip
                    return-value skip
                    view-as alert-box error .
                leave del-doc .
            end.
            find first r-doc exclusive-lock
                where recid( r-doc ) = del-rec
                .
            assign
                r-doc.is-del = true
                .
            delete r-doc.
        end.
        run waitfram-hide in this-procedure .
    end.
END PROCEDURE.
PROCEDURE UI-on :
ENABLE
        b-quit
        b-lkp
        b-print
        b-sch
        b-hist
        b-help
        ed-notes
        br-r-docs
        WITH FRAME d-all-r-docs.
    ASSIGN
        r-doc.state-level-water:READ-ONLY in browse br-r-docs = YES
    .
    run OpenBr in this-procedure .
END PROCEDURE.
PROCEDURE userlogrvs :
define input parameter p-vid-action as integer  no-undo .
define input parameter p-mess as char no-undo.
    define variable v-person as character no-undo.
    define variable v-vid-param  as longchar no-undo .
  define variable v-result as integer no-undo.
  define variable varshift-date as date no-undo.
  define variable  varshift-num as integer no-undo.
  define variable varshift-name as char no-undo.
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  r-doc.obj-type
  ,input  r-doc.obj-code
  ,output varshift-date
  ,output varshift-num
  ,output varshift-name
  ) no-error .
        for first  ub.clients where ub.clients.obj-type = 'чел':U and  ub.clients.obj-code = ub.c-rvs-doc.boss no-lock :
            v-person = clients.obj-name.
        end.
    v-vid-param =
        "Initiator=" + "User" + chr(4) +
        "ResponsiblePerson=" + (if v-person <> ?  then v-person else "") + chr(4) +
        "SHOP_NUM=" + string(r-doc.obj-code) + chr(4) +
        "DocNum=" + string(r-doc.rvs-code) + chr(4) +
        "FactDate=" + (if string(r-doc.fact-date) = ? then '' else string(r-doc.fact-date)) + chr(4) +
        "DocType=" + string(r-doc.rvs-type) + chr(4) +
        "SHIFT_NUM_DOC=" + (if string(r-doc.shift-num) = ? then '' else string(r-doc.shift-num)) + (if string(r-doc.shift-date) = ? then '' else string(r-doc.shift-date ,  "99999999" )) + chr(4) +
        "SHIFT_NUM=" + (if string(varshift-num) = ? then '' else string(varshift-num)) + (if string(varshift-date) = ? then '' else string(varshift-date, "99999999")) + chr(4) +
        "Status=" + string(r-doc.status_) + chr(4) +
        "RESULT=" + string( 1 ) + chr(4) +
        "Description=" + p-mess no-error.
        run trg/userlog.p (
            input if p-vid-action = 60 then 'delete_err':U else 'update_err':U
            , input 'rvs-doc':U
            , input ( buffer r-doc :handle )
            , input p-vid-action
            , input v-vid-param
            ) no-error.
        if error-status :error
            then
        do:
            message substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                , chr(10)
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) )
                view-as alert-box.
            return no-apply.
        end.
END PROCEDURE.
FUNCTION mark-string RETURNS CHARACTER
    ( p-rec as recid ) :
    def buffer loc-rvs-doc for ub.rvs-doc  .
    find first loc-rvs-doc no-lock where  recid ( loc-rvs-doc ) = p-rec no-error  .
    if error-status :error then return '' .
    if can-do (del-list, string (recid (loc-rvs-doc))) then RETURN "*".
    else RETURN "".
END FUNCTION.
FUNCTION get-input-type RETURNS CHARACTER
    ( p-rec as recid ) :
    def buffer loc-rvs-doc for ub.rvs-doc  .
    define buffer loc-rvs-line for ub.rvs-line .
    define buffer loc-rvs-line-attr for ub.rvs-line-attr .
    define variable v-doc-input-type as character no-undo .
    define variable v-input-type-list as character no-undo .
    find first loc-rvs-doc no-lock where  recid ( loc-rvs-doc ) = p-rec no-error  .
    for each loc-rvs-line no-lock where loc-rvs-line.rvs-code = loc-rvs-doc.rvs-code :
      find first loc-rvs-line-attr no-lock
            where loc-rvs-line-attr.obj-code  = loc-rvs-line.obj-code
            and loc-rvs-line-attr.obj-type  = loc-rvs-line.obj-type
            and loc-rvs-line-attr.gds-code  = loc-rvs-line.gds-code
            and loc-rvs-line-attr.pl-code   = loc-rvs-line.pl-code
            and loc-rvs-line-attr.rvs-code  = loc-rvs-line.rvs-code
            and loc-rvs-line-attr.attr-code = 'input-type'
            no-error.
      if available loc-rvs-line-attr
      then do :
        v-input-type-list = v-input-type-list + ',' + loc-rvs-line-attr.attr-value .
      end.
    end.
    if trim(v-input-type-list) = ""
    then do :
      for each loc-rvs-line no-lock where loc-rvs-line.rvs-code = loc-rvs-doc.rvs-code :
        find first loc-rvs-line-attr no-lock
              where loc-rvs-line-attr.obj-code  = loc-rvs-line.obj-code
              and loc-rvs-line-attr.obj-type  = loc-rvs-line.obj-type
              and loc-rvs-line-attr.gds-code  = loc-rvs-line.gds-code
              and loc-rvs-line-attr.pl-code   = loc-rvs-line.pl-code
              and loc-rvs-line-attr.rvs-code  = loc-rvs-line.rvs-code
              and loc-rvs-line-attr.attr-code = 'input-type-p'
              no-error.
        if available loc-rvs-line-attr
        then do :
          v-input-type-list = v-input-type-list + ',' + loc-rvs-line-attr.attr-value .
        end.
        find first loc-rvs-line-attr no-lock
              where loc-rvs-line-attr.obj-code  = loc-rvs-line.obj-code
              and loc-rvs-line-attr.obj-type  = loc-rvs-line.obj-type
              and loc-rvs-line-attr.gds-code  = loc-rvs-line.gds-code
              and loc-rvs-line-attr.pl-code   = loc-rvs-line.pl-code
              and loc-rvs-line-attr.rvs-code  = loc-rvs-line.rvs-code
              and loc-rvs-line-attr.attr-code = 'input-type-t'
              no-error.
        if available loc-rvs-line-attr
        then do :
          v-input-type-list = v-input-type-list + ',' + loc-rvs-line-attr.attr-value .
        end.
        find first loc-rvs-line-attr no-lock
              where loc-rvs-line-attr.obj-code  = loc-rvs-line.obj-code
              and loc-rvs-line-attr.obj-type  = loc-rvs-line.obj-type
              and loc-rvs-line-attr.gds-code  = loc-rvs-line.gds-code
              and loc-rvs-line-attr.pl-code   = loc-rvs-line.pl-code
              and loc-rvs-line-attr.rvs-code  = loc-rvs-line.rvs-code
              and loc-rvs-line-attr.attr-code = 'input-type-l'
              no-error.
        if available loc-rvs-line-attr
        then do :
          v-input-type-list = v-input-type-list + ',' + loc-rvs-line-attr.attr-value .
        end.
      end.
    end .
    v-input-type-list = left-trim(v-input-type-list, ",") .
    if can-do(v-input-type-list, 'а')
    and not can-do(v-input-type-list, 'ф')
    and not can-do(v-input-type-list, 'ак')
    and not can-do(v-input-type-list, 'фк')
    and not can-do(v-input-type-list, 'п')
    then v-doc-input-type = 'а'.
    if can-do(v-input-type-list, 'ф')
    and not can-do(v-input-type-list, 'а')
    and not can-do(v-input-type-list, 'ак')
    and not can-do(v-input-type-list, 'фк')
    and not can-do(v-input-type-list, 'п')
    then v-doc-input-type = 'ф'.
    if  not can-do(v-input-type-list, 'ф')
    and can-do(v-input-type-list, 'ак')
    and not can-do(v-input-type-list, 'п')
    then v-doc-input-type = 'ак'.
    if ((can-do(v-input-type-list, 'ф')
    or can-do(v-input-type-list, 'п'))
    and can-do(v-input-type-list, 'а'))
    or can-do(v-input-type-list, 'фк')
    then v-doc-input-type = 'фк'.
    if can-do(v-input-type-list, 'р')
    and not can-do(v-input-type-list, 'а')
    and not can-do(v-input-type-list, 'ф')
    and not can-do(v-input-type-list, 'к')
    and not can-do(v-input-type-list, 'п')
    then v-doc-input-type = 'р'.
    if v-doc-input-type = 'а'
    and (can-do(v-input-type-list, 'р')
      or can-do(v-input-type-list, ''))
    then v-doc-input-type = 'ак'.
    if v-doc-input-type = 'ф'
    and (can-do(v-input-type-list, 'р')
      or can-do(v-input-type-list, ''))
    then v-doc-input-type = 'фк'.
    if v-doc-input-type = ? then v-doc-input-type = '' .
    return v-doc-input-type .
END FUNCTION.
FUNCTION shift-name RETURNS CHARACTER
    ( p-rec as recid ) :
    def buffer loc-rvs-doc for ub.rvs-doc  .
    find first loc-rvs-doc no-lock where  recid ( loc-rvs-doc ) = p-rec no-error  .
    if error-status :error then return '' .
    if loc-rvs-doc.shift-date = ? then
    do:
        return "":u.
    end.
    else
    do:
        if loc-rvs-doc.shift-num = integer(loc-rvs-doc.shift-name) then
        do:
            return loc-rvs-doc.shift-name.
        end.
        else
        do:
            return loc-rvs-doc.shift-name + "(" + string(loc-rvs-doc.shift-num) + ")".
        end.
    end.
end function.
