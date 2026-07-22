DEFINE BUFFER locked_dis-time-rule FOR ub.dis-time-rule.
DEFINE BUFFER root_dis-time-rule FOR ub.dis-time-rule.
DEFINE BUFFER template_dis-time-rule FOR ub.dis-time-rule.
DEFINE TEMP-TABLE term_dis-time-rule NO-UNDO LIKE ub.dis-time-rule.
DEFINE TEMP-TABLE tt-dis-time-rule NO-UNDO LIKE ub.dis-time-rule.
DEFINE TEMP-TABLE tt0-term_dis-time-rule NO-UNDO LIKE ub.dis-time-rule.
DEFINE INPUT PARAMETER parparentproc AS widget-handle NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS character NO-UNDO.
DEFINE INPUT PARAMETER p-templ-rl-root like ub.dis-time-rule.templ-rl-root NO-UNDO.
DEFINE INPUT PARAMETER p-time-rule-num LIKE ub.dis-time-rule.time-rule-num NO-UNDO.
define input parameter p-upper-time-rule-num like ub.dis-time-rule.upper-time-rule-num no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-recid AS recid NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "–Â‰‡ÍÚËÓ‚‡ÌËÂ ‡ÒÔËÒ‡ÌËÈ".
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
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure dtr-code :
  do
  on error undo, return error
  :
    define input  parameter  p-templ-rl-root     like ub.dis-time-rule.templ-rl-root     no-undo .
    define output parameter  p-des               like ub.dis-time-rule.des               no-undo .
    define output parameter  p-upper-time-rule-num    like ub.dis-time-rule.upper-time-rule-num    no-undo .
    define output parameter  p-value-type        like ub.dis-time-rule.value-type        no-undo .
    define output parameter  p-level-1 as character no-undo .
    define output parameter  p-level-2 as character no-undo .
    define output parameter  p-output-display as logical   no-undo .
    define output parameter  p-tree           as char  no-undo .
    define output parameter  p-other          as character no-undo .
    define variable v-templ-rl-root like ub.dis-time-rule.templ-rl-root no-undo .
    define buffer buf_dis-time-rule for ub.dis-time-rule .
    define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
    if p-templ-rl-root < 50000 then
    v-templ-rl-root = (p-templ-rl-root + 50000).
    else v-templ-rl-root = p-templ-rl-root.
    find first buf_dis-time-rule no-lock where
              buf_dis-time-rule.time-rule-num = v-templ-rl-root no-error .
    if not available buf_dis-time-rule then do:
      undo, return error substitute("ÌÂËÁ‚ÂÒÚÌ˚È ÚËÔ ‡ÒÔËÒ‡ÌËˇ &1", p-templ-rl-root) .
    end.
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = 0
        and buf_dis-cfg-rule.time-templ-rl-root = p-templ-rl-root
        and buf_dis-cfg-rule.pos-type = '':U
        and buf_dis-cfg-rule.table-name = '':U
        and buf_dis-cfg-rule.discnt-role = '':U
        and buf_dis-cfg-rule.self-nonunique = '':U
            no-error.
    if not available buf_Dis-cfg-rule then do:
        undo, return error substitute("ÌÂËÁ‚ÂÒÚÌ˚È ÚËÔ ‡ÒÔËÒ‡ÌËˇ &1", p-templ-rl-root ).
    end.
    assign
    p-des = buf_dis-time-rule.des
    p-upper-time-rule-num = (buf_dis-time-rule.upper-time-rule-num - 50000)
    p-value-type = buf_dis-time-rule.value-type
    p-level-1 = entry(1, buf_dis-cfg-rule.other-inf, ";":U)
    p-level-2 = (if num-entries(buf_dis-cfg-rule.other-inf, ";":U) > 1
                 then entry(2, buf_dis-cfg-rule.other-inf, ";":U)
                 else '')
    p-output-display = (buf_dis-time-rule.sts = integer('0':U))
    p-tree = buf_dis-time-rule.uniq-field
    p-other = buf_dis-time-rule.other-inf
    .
  end.
end procedure.
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure dr-code :
  do
  on error undo, return error
  :
    define input  parameter  p-templ-rl-root     like ub.dis-rule.templ-rl-root     no-undo .
    define output parameter  p-des               like ub.dis-rule.des               no-undo .
    define output parameter  p-discnt-type       like ub.dis-rule.discnt-type       no-undo .
    define output parameter  p-subject-type      like ub.dis-rule.subject-type      no-undo .
    define output parameter  p-value-type        like ub.dis-rule.value-type        no-undo .
    define output parameter  p-level-1           as character no-undo .
    define output parameter  p-level-2           as character no-undo .
    define output parameter  p-global             as integer no-undo .
    define output parameter  p-host               as integer no-undo .
    define output parameter  p-object             as integer no-undo .
    define output parameter  p-output-display as logical   no-undo .
    define output parameter  p-tree           as char  no-undo .
    define output parameter  p-other          as character no-undo .
    define variable v-other as character no-undo .
    define buffer buf_dis-rule for ub.dis-rule .
    define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-templ-rl-root no-error.
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
        and buf_dis-cfg-rule.pos-type = '':U
        and buf_dis-cfg-rule.table-name = '':U
        and buf_dis-cfg-rule.discnt-role = '':U
        and buf_dis-cfg-rule.self-nonunique = '':U
            no-error.
    if not available buf_Dis-cfg-rule then do:
        undo, return error substitute("ÌÂËÁ‚ÂÒÚÌ˚È ¯‡·ÎÓÌ ÒÍË‰ÍË &1", p-templ-rl-root ).
    end.
    assign
    p-des = buf_dis-rule.des
    p-discnt-type = buf_dis-rule.discnt-type
    p-subject-type = buf_dis-rule.subject-type
    p-value-type = buf_dis-rule.value-type
    p-global = (if available buf_dis-cfg-rule
                then buf_dis-cfg-rule.has-global
                else 0)
    p-host = (if available buf_dis-cfg-rule
              then buf_dis-cfg-rule.has-host
              else 0)
    p-object = (if available buf_dis-cfg-rule
              then buf_dis-cfg-rule.has-obj
              else 0)
    p-output-display = (buf_dis-rule.sts = integer('0':U))
    p-tree = buf_Dis-rule.uniq-field
    p-other = buf_dis-rule.other-inf
    p-level-1 = entry(1, buf_dis-cfg-rule.other-inf, ";":U)
    p-level-2 = (if num-entries(buf_dis-cfg-rule.other-inf, ";":U) > 1
                 then entry(2, buf_dis-cfg-rule.other-inf, ";":U)
                 else '')
    .
  end.
end procedure.
define temp-table temp-drt-prop no-undo like ub.drt-prop.
procedure disrules-fill-properties:
define input  parameter p-templ-rl-root as integer   no-undo .
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf_temp-drt-prop for temp-drt-prop.
do
on error undo, return error return-value
:
  for each buf_temp-drt-prop:
    delete buf_temp-drt-prop.
  end.
  for each buf_drt-prop where buf_drt-prop.templ-rl-root = p-templ-rl-root:
    create buf_temp-drt-prop.
    buffer-copy buf_drt-prop to buf_temp-drt-prop.
  end.
end.
end procedure.
procedure disrules-get-interface-form :
define input parameter p-templ-rl-root like ub.dis-rule.templ-rl-root no-undo .
define output parameter p-form-name as character no-undo .
define buffer buf_temp-drt-prop for temp-drt-prop.
define buffer buf_drt-prop for ub.drt-prop.
find first buf_temp-drt-prop where
          buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
      and buf_temp-drt-prop.upper-prop-code = "InputForm"
      and buf_temp-drt-prop.prop-code = "FormName" no-error.
if not available buf_temp-drt-prop then do:
  find first buf_drt-prop where
            buf_drt-prop.templ-rl-root = p-templ-rl-root
        and buf_drt-prop.upper-prop-code = "InputForm"
        and buf_drt-prop.prop-code = "FormName" no-error.
  if available buf_drt-prop then do:
    p-form-name = buf_drt-prop.property-value.
  end.
  else do:
    p-form-name = "ref/dis-ruli.w".
  end.
end.
else do:
  p-form-name = buf_temp-drt-prop.property-value.
end.
end procedure.
~
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
     label "—ÚÓÔ"
     size 10 by 1 tooltip "ŒÒÚÓÌÓ‚ËÚ¸ ÔÓˆÂÒÒ".
define button B-viewProcInfo
     label "»ÌÙÓÏ‡ˆËˇ"
     size 15 by 1 tooltip "»ÌÙÓÏ‡ˆËˇ Ó ÔÓˆÂÒÒ".
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
                                    if vtime eq ? then "" else substitute (" œÓ¯ÎÓ: &1 ÒÂÍ" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " ËÁ " + string(mWaitFramTimeOut) + " ÒÂÍ. " else "",
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
define variable v-time-rule-num          like ub.dis-time-rule.time-rule-num          no-undo .
define variable vt-des               like ub.dis-time-rule.des               no-undo .
define variable vt-level-1           as character no-undo .
define variable vt-level-2           as character no-undo .
define variable vt-upper-time-rule-num    like ub.dis-time-rule.upper-time-rule-num    no-undo .
define variable vt-value-type        like ub.dis-time-rule.value-type        no-undo .
define variable vt-output-display as logical   no-undo .
define variable vt-tree              as character no-undo .
define variable vt-other          as character no-undo .
DEFINE VARIABLE v-tab-order       AS CHARACTER NO-UNDO.
DEFINE variable v-display-time-from          AS CHARACTER no-undo .
DEFINE variable v-display-time-to            AS CHARACTER no-undo .
define buffer buf_temp-drt-prop for temp-drt-prop.
DEFINE BUTTON B-add
     LABEL "&ƒÓ·‡‚ËÚ¸"
     SIZE 10 BY 1.
DEFINE BUTTON B-del
     LABEL "&”‰‡ÎËÚ¸"
     SIZE 10 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&¬‚Ó‰"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-exit-1
     LABEL "¬‚Ó‰"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "œÓÏÓ&˘¸"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-hist
     LABEL "»Ò&ÚÓËˇ"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&ŒÚÏÂÌ‡"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-quit-1
     LABEL "ŒÚÏÂÌ‡"
     SIZE 10 BY 1.
DEFINE VARIABLE fhour AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2.88 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fmin AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2.88 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fsec AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2.88 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE lfromt AS CHARACTER FORMAT "X(256)":U INITIAL "—"
      VIEW-AS TEXT
     SIZE 3.5 BY .67 NO-UNDO.
DEFINE VARIABLE ltot AS CHARACTER FORMAT "X(256)":U INITIAL "ƒÓ"
      VIEW-AS TEXT
     SIZE 3.5 BY .67 NO-UNDO.
DEFINE VARIABLE thour AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2.88 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE tmin AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2.88 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE tsec AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2.88 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE RS-week-day AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "œÓÌÂ‰ÂÎ¸ÌËÍ", 1,
"¬ÚÓÌËÍ", 2,
"—Â‰‡", 3,
"◊ÂÚ‚Â„", 4,
"œˇÚÌËˆ‡", 5,
"—Û··ÓÚ‡", 6,
"¬ÓÒÍÂÒÂÌ¸Â", 7,
"¬ÒÂ ‰ÌË ÌÂ‰ÂÎË", 0
     SIZE 17 BY 7.75 NO-UNDO.
DEFINE QUERY br-term-dtr FOR
      tt0-term_dis-time-rule SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      tt-dis-time-rule SCROLLING.
DEFINE BROWSE br-term-dtr
  QUERY br-term-dtr NO-LOCK DISPLAY
      tt0-term_dis-time-rule.date-from FORMAT "99/99/9999":U
      tt0-term_dis-time-rule.date-to FORMAT "99/99/9999":U
      v-display-time-from COLUMN-LABEL "¬ÂÏˇ!Ì‡˜‡Î‡" FORMAT "X(8)":U
            WIDTH 9
      v-display-time-to COLUMN-LABEL "¬ÂÏˇ!ÍÓÌˆ‡" FORMAT "X(8)":U
            WIDTH 9
      tt0-term_dis-time-rule.week-day-0 COLUMN-LABEL "ƒÕ" FORMAT "*/":U
            WIDTH 3
      tt0-term_dis-time-rule.week-day-1 COLUMN-LABEL "œÌ" FORMAT "œÌ/":U
            WIDTH 3
      tt0-term_dis-time-rule.week-day-2 COLUMN-LABEL "¬Ú" FORMAT "¬Ú/":U
            WIDTH 3
      tt0-term_dis-time-rule.week-day-3 COLUMN-LABEL "—" FORMAT "—/":U
            WIDTH 3
      tt0-term_dis-time-rule.week-day-4 COLUMN-LABEL "◊Ú" FORMAT "◊Ú/":U
      tt0-term_dis-time-rule.week-day-5 COLUMN-LABEL "œÚÌ" FORMAT "œÚÌ/":U
            WIDTH 3
      tt0-term_dis-time-rule.week-day-6 COLUMN-LABEL "—·" FORMAT "—·/":U
            WIDTH 3
      tt0-term_dis-time-rule.week-day-7 COLUMN-LABEL "¬Ò" FORMAT "¬Ò/":U
      tt0-term_dis-time-rule.month-day FORMAT ">9":U
      tt0-term_dis-time-rule.des FORMAT "X(255)":U
      tt0-term_dis-time-rule.time-rule-num FORMAT ">>>>>>>>9":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 63 BY 14.5
         FONT 4
         TITLE "ƒÂÚ‡ÎËÁ‡ˆËˇ" EXPANDABLE.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-hist AT ROW 1 COL 61
     B-Help AT ROW 1 COL 71
     tt-dis-time-rule.des AT ROW 2.25 COL 9 COLON-ALIGNED
          LABEL "ŒÔËÒ‡ÌËÂ"
          VIEW-AS FILL-IN
          SIZE 84 BY 1
     B-add AT ROW 4 COL 59
     B-del AT ROW 4 COL 69
     tt-dis-time-rule.date-from AT ROW 5 COL 15 COLON-ALIGNED
          LABEL "Õ‡˜‡ÎÓ ÔÂËÓ‰‡"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          FGCOLOR 4
     br-term-dtr AT ROW 5.25 COL 36
     tt-dis-time-rule.date-to AT ROW 6.25 COL 15 COLON-ALIGNED
          LABEL " ÓÌÂˆ ÔÂËÓ‰‡"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          FGCOLOR 4
     fhour AT ROW 8 COL 3.5 COLON-ALIGNED NO-LABEL
     fmin AT ROW 8 COL 7.5 COLON-ALIGNED NO-LABEL
     fsec AT ROW 8 COL 11.5 COLON-ALIGNED NO-LABEL
     thour AT ROW 9.25 COL 3.5 COLON-ALIGNED NO-LABEL
     tmin AT ROW 9.25 COL 7.5 COLON-ALIGNED NO-LABEL
     tsec AT ROW 9.25 COL 11.5 COLON-ALIGNED NO-LABEL
     tt-dis-time-rule.month-day AT ROW 10.75 COL 12.5 COLON-ALIGNED
          LABEL "ƒÂÌ¸ ÏÂÒˇˆ‡"
          VIEW-AS FILL-IN
          SIZE 3 BY 1
          FGCOLOR 4
     tt-dis-time-rule.week-day-1 AT ROW 12 COL 1.5
          LABEL "œÓÌÂ‰ÂÎ¸ÌËÍ"
          VIEW-AS TOGGLE-BOX
          SIZE 17 BY 1
     RS-week-day AT ROW 12 COL 18.5 NO-LABEL
     tt-dis-time-rule.week-day-2 AT ROW 13 COL 1.5
          LABEL "¬ÚÓÌËÍ"
          VIEW-AS TOGGLE-BOX
          SIZE 17 BY 1
     tt-dis-time-rule.week-day-3 AT ROW 14 COL 1.5
          LABEL "—Â‰‡"
          VIEW-AS TOGGLE-BOX
          SIZE 17 BY 1
     tt-dis-time-rule.week-day-4 AT ROW 15 COL 1.5
          LABEL "◊ÂÚ‚Â„"
          VIEW-AS TOGGLE-BOX
          SIZE 17 BY 1
     tt-dis-time-rule.week-day-5 AT ROW 16 COL 1.5
          LABEL "œˇÚÌËˆ‡"
          VIEW-AS TOGGLE-BOX
          SIZE 17 BY 1
     tt-dis-time-rule.week-day-6 AT ROW 17 COL 1.5
          LABEL "—Û··ÓÚ‡"
          VIEW-AS TOGGLE-BOX
          SIZE 17 BY 1
     tt-dis-time-rule.week-day-7 AT ROW 18 COL 1.5
          LABEL "¬ÓÒÍÂÒÂÌ¸Â"
          VIEW-AS TOGGLE-BOX
          SIZE 17 BY 1
     B-exit-1 AT ROW 20 COL 3
     B-quit-1 AT ROW 20 COL 13
     lfromt AT ROW 8.25 COL 1 NO-LABEL
     ltot AT ROW 9.25 COL 1 NO-LABEL
     SPACE(94.74) SKIP(12.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "–‡ÒÔËÒ‡ÌËÂ ÚËÔ‡"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-add:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-del:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-exit-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-quit-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt0-term_dis-time-rule.date-from:VISIBLE IN BROWSE br-term-dtr = FALSE
       tt0-term_dis-time-rule.date-to:VISIBLE IN BROWSE br-term-dtr = FALSE
       tt0-term_dis-time-rule.week-day-0:VISIBLE IN BROWSE br-term-dtr = FALSE
       tt0-term_dis-time-rule.week-day-1:VISIBLE IN BROWSE br-term-dtr = FALSE
       tt0-term_dis-time-rule.week-day-2:VISIBLE IN BROWSE br-term-dtr = FALSE
       tt0-term_dis-time-rule.week-day-3:VISIBLE IN BROWSE br-term-dtr = FALSE
       tt0-term_dis-time-rule.week-day-4:VISIBLE IN BROWSE br-term-dtr = FALSE
       tt0-term_dis-time-rule.week-day-5:VISIBLE IN BROWSE br-term-dtr = FALSE
       tt0-term_dis-time-rule.week-day-6:VISIBLE IN BROWSE br-term-dtr = FALSE
       tt0-term_dis-time-rule.week-day-7:VISIBLE IN BROWSE br-term-dtr = FALSE
       tt0-term_dis-time-rule.month-day:VISIBLE IN BROWSE br-term-dtr = FALSE.
ASSIGN
       tt-dis-time-rule.date-from:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt-dis-time-rule.date-to:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       fmin:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       fsec:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       lfromt:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       ltot:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt-dis-time-rule.month-day:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       RS-week-day:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       thour:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tmin:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tsec:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt-dis-time-rule.week-day-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt-dis-time-rule.week-day-2:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt-dis-time-rule.week-day-3:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt-dis-time-rule.week-day-4:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt-dis-time-rule.week-day-5:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt-dis-time-rule.week-day-6:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt-dis-time-rule.week-day-7:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
  IF b-exit-1:VISIBLE IN FRAME Dialog-Frame THEN DO:
      BELL.
      RETURN NO-APPLY.
  END.
  RUN proc-b-add IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
      RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
IF b-exit-1:VISIBLE IN FRAME Dialog-Frame THEN DO:
    BELL.
    RETURN NO-APPLY.
END.
  RUN proc-b-del IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
    RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF B-exit-1 IN FRAME Dialog-Frame
DO:
  RUN proc-b-exit-1 IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-hist IN FRAME Dialog-Frame
DO:
  define variable v-rid-list as character no-undo.
  if NOT available locked_dis-time-rule then return no-apply.
  run ref/disctrls.w (
                   INPUT parParentProc
                  ,input "":U
                  ,input "rl-root":U
                  ,input tt-dis-time-rule.time-rule-num
                  ,input tt-dis-time-rule.upper-time-rule-num
                  ,input-output v-rid-list ).
END.
ON CHOOSE OF B-quit-1 IN FRAME Dialog-Frame
DO:
  RUN proc-b-quit-1 IN THIS-PROCEDURE.
END.
ON ROW-DISPLAY OF br-term-dtr IN FRAME Dialog-Frame
DO:
  ASSIGN
  v-display-time-from = STRING(tt0-term_dis-time-rule.time-from, "HH:MM:SS")
  v-display-time-to   = STRING(tt0-term_dis-time-rule.time-to, "HH:MM:SS").
  .
END.
ON LEAVE OF fhour IN FRAME Dialog-Frame
DO:
  assign fhour.
  run check-time in this-procedure (input fhour:screen-value, input "hour":U) no-error.
  if error-status:error then return no-apply.
END.
ON LEAVE OF fmin IN FRAME Dialog-Frame
DO:
  assign fmin.
  run check-time in this-procedure (input fmin:screen-value, input "min":U) no-error.
  if error-status:error then return no-apply.
END.
ON LEAVE OF fsec IN FRAME Dialog-Frame
DO:
  assign fsec.
  run check-time in this-procedure (input fsec:screen-value, input "sec":U)  no-error.
  if error-status:error then return no-apply.
END.
ON LEAVE OF thour IN FRAME Dialog-Frame
DO:
  assign fhour.
  run check-time in this-procedure (input fhour:screen-value, input "hour":U) no-error.
  if error-status:error then return no-apply.
END.
ON LEAVE OF tmin IN FRAME Dialog-Frame
DO:
  assign fmin.
  run check-time in this-procedure (input fmin:screen-value, input "min":U) no-error.
  if error-status:error then return no-apply.
END.
ON LEAVE OF tsec IN FRAME Dialog-Frame
DO:
  assign fsec.
  run check-time in this-procedure (input fsec:screen-value, input "sec":U)  no-error.
  if error-status:error then return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Œ¯Ë·Í‡ ÔË ‚˚ÁÓ‚Â ÔÓÏÓ˘Ë"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                                hh:TOOLTIP = "œÓÏÓ˘¸" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "œÂ˜‡Ú¸" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "»ÒÚÓËˇ" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "”ÒÚ‡ÌÓ‚Í‡ ‘ËÎ¸Ú‡" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "»ÒÚÓËˇ ÔÓÎ¸ÁÓ‚‡ÚÂÎˇ" .
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ ¡Ë·ÎËÓÚÂÍ‡ ËÁÏÂÌÂÌËˇ ‡ÁÏÂÓ‚ ÓÍÌ‡".
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
        v-diasize-browse-handle     = browse br-term-dtr :handle
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  IF p-mode <> 'ƒŒ¡¿¬À≈Õ»≈':U
  and p-mode <> 'œ–Œ—ÃŒ“–':U
  and p-mode <> '»«Ã≈Õ≈Õ»≈':U THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "ÕÂ‚ÂÌÓÂ ÁÌ‡˜ÂÌËÂ Ô‡‡ÏÂÚ‡ p-mode" p-mode
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  IF p-mode <> 'ƒŒ¡¿¬À≈Õ»≈':U THEN DO:
  END.
  for each tt-dis-time-rule:
    delete tt-dis-time-rule.
  end.
  for each tt0-term_dis-time-rule:
    delete tt0-term_dis-time-rule.
  end.
if p-mode = '»«Ã≈Õ≈Õ»≈':U
  or p-mode = 'œ–Œ—ÃŒ“–':U then do:
    if p-mode = '»«Ã≈Õ≈Õ»≈':U then do:
      find first locked_dis-time-rule EXclusive-lock where
                   recid(locked_dis-time-rule) = p-recid no-wait no-error.
      if locked locked_dis-time-rule then do:
        message
        vss-workfile vss-revision vss-description skip
         "«‡ÔËÒ¸ –¿—œ»—¿Õ»≈ Á‡ÌˇÚ‡"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_dis-time-rule no-lock where
                       recid(locked_dis-time-rule) = p-recid no-error .
      if not avail locked_dis-time-rule then do:
        find first locked_dis-time-rule no-lock where
                   locked_dis-time-rule.time-rule-num = p-time-rule-num no-error .
      end.
    end.
    if not available locked_dis-time-rule then do:
      message
      vss-workfile vss-revision vss-description skip
      "ÕÂ Ì‡È‰ÂÌ‡ Á‡ÔËÒ¸ –¿—œ»—¿Õ»ﬂ Ò ÌÓÏÂÓÏ" p-time-rule-num
      view-as alert-box error .
      undo, return error.
    end.
    if locked_dis-time-rule.time-rule-num <= 99999
    and p-mode = '»«Ã≈Õ≈Õ»≈':U then do:
      message
      vss-workfile vss-revision vss-description skip
      "ÕÂÎ¸Áˇ Â‰‡ÍÚËÓ‚‡Ú¸ ÿ¿¡ÀŒÕ€ –¿—œ»—¿Õ»…"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-dis-time-rule.
    buffer-copy locked_dis-time-rule to tt-dis-time-rule
    .
   end.
   else do:
       FIND FIRST template_dis-time-rule NO-LOCK WHERE
                    template_dis-time-rule.time-rule-num = p-templ-rl-root .
       create tt-dis-time-rule.
       BUFFER-COPY template_dis-time-rule TO tt-dis-time-rule
       ASSIGN
       tt-dis-time-rule.upper-time-rule-num = template_dis-time-rule.time-rule-num
       tt-dis-time-rule.templ-rl-root  = template_dis-time-rule.time-rule-num
       tt-dis-time-rule.root        = yes
       tt-dis-time-rule.des = trim(template_dis-time-rule.des, "@":U)
       .
  end.
  run dtr-code  in this-procedure (
     input  (if p-templ-rl-root > 0 then p-templ-rl-root else tt-dis-time-rule.templ-rl-root)
    ,output vt-des
    ,output vt-upper-time-rule-num
    ,output vt-value-type
    ,output vt-level-1
    ,output vt-level-2
    ,output vt-output-display
    ,output vt-tree
    ,output vt-other
                               ) no-error .
  IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE
    vss-workfile vss-revision vss-description skip
    "ÕÂ‚ÂÌÓÂ ÁÌ‡˜ÂÌËÂ Ô‡‡ÏÂÚ‡ p-templ-rl-root" p-templ-rl-root SKIP
     error-status:get-message(1) SKIP
     RETURN-VALUE
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
  run disrules-fill-properties in this-procedure ( input p-templ-rl-root).
  if p-upper-time-rule-num > 99999 then do:
    assign
    vt-tree = "":U.
  end.
  RUN fill-tables IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
  RUN MYenable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE check-time :
define input parameter p-screen-value as integer no-undo.
define input parameter p-mode as character no-undo.
define variable v-limit as integer no-undo.
CASE p-mode:
    when "hour":U then do:
         v-limit = 23.
    end.
    when "min":U then do:
          v-limit = 59.
    end.
    when "sec" then do:
          v-limit = 59.
    end.
END.
  if int(p-screen-value) > v-limit then do:
    bell.
    Message "ÕÂ‚ÂÌÓÂ ‚ÂÏˇ!" view-as alert-box ERROR.
    return error.
  end.
 if error-status:error then return error.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE display-hide-fields :
DEFINE INPUT PARAMETER p-tree AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-other AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-main AS LOGICAL NO-UNDO.
DEFINE INPUT PARAMETER p-display-hide AS integer NO-UNDO.
CASE p-display-hide:
    WHEN 1 THEN DO:
      IF p-main THEN DO:
        IF lookup("time-from":U, vt-level-1) > 0
        THEN DO:
           DISPLAY
           fhour fmin fsec
           WITH FRAME Dialog-Frame.
           ENABLE
           fhour WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
           fmin WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
           fsec WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
           WITH FRAME Dialog-Frame.
        END.
        else do:
          hide
          fhour fmin fsec
          in FRAME Dialog-Frame.
        end.
        IF lookup("time-to", vt-level-1) > 0 THEN DO:
           DISPLAY
           thour tmin tsec
           WITH FRAME Dialog-Frame.
           ENABLE
           thour WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
           tmin WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
           tsec WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
           WITH FRAME Dialog-Frame.
        END.
        else do:
          hide
          thour tmin tsec
          in FRAME Dialog-Frame.
        end.
        IF lookup("date-from":U, vt-level-1) >  0 THEN DO:
           DISPLAY
           tt-dis-time-rule.date-from
           WITH FRAME Dialog-Frame.
           ENABLE
           tt-dis-time-rule.date-from WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
           WITH FRAME Dialog-Frame.
        END.
        else do:
          hide
          tt-dis-time-rule.date-from
          in FRAME Dialog-Frame.
        end.
        IF lookup("date-to":U, vt-level-1) >  0 THEN DO:
           DISPLAY
           tt-dis-time-rule.date-to
           WITH FRAME Dialog-Frame.
           ENABLE
           tt-dis-time-rule.date-to WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
           WITH FRAME Dialog-Frame.
        END.
        else do:
          hide
          tt-dis-time-rule.date-to
          in FRAME Dialog-Frame.
        end.
        IF lookup("month-day":U, vt-level-1) >  0 THEN DO:
           DISPLAY
           tt-dis-time-rule.month-day
           WITH FRAME Dialog-Frame.
           ENABLE
           tt-dis-time-rule.month-day WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
           WITH FRAME Dialog-Frame.
        END.
        else do:
          hide
          tt-dis-time-rule.month-day
          in FRAME Dialog-Frame.
        end.
        IF lookup("week-day-1":U, vt-level-1) >  0
        AND lookup("week-day-a":U, p-other, ";") = 0
        AND lookup("week-day-b":U, p-other, ";") = 0 THEN DO:
           DISPLAY
           tt-dis-time-rule.week-day-1
           WITH FRAME Dialog-Frame.
           ENABLE
           tt-dis-time-rule.week-day-1 WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
           WITH FRAME Dialog-Frame.
        END.
        else do:
          hide
          tt-dis-time-rule.week-day-1
          in FRAME Dialog-Frame.
        end.
        IF lookup("week-day-2":U, vt-level-1) >  0
        AND lookup("week-day-a":U, p-other, ";") = 0
        AND lookup("week-day-b":U, p-other, ";") = 0 THEN DO:
           DISPLAY
           tt-dis-time-rule.week-day-2
           WITH FRAME Dialog-Frame.
           ENABLE
           tt-dis-time-rule.week-day-2 WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
           WITH FRAME Dialog-Frame.
        END.
        else do:
          hide
          tt-dis-time-rule.week-day-2
          in FRAME Dialog-Frame.
        end.
        IF lookup("week-day-3":U, vt-level-1) >  0
        AND lookup("week-day-a":U, p-other, ";") = 0
        AND lookup("week-day-b":U, p-other, ";") = 0 THEN DO:
           DISPLAY
           tt-dis-time-rule.week-day-3
           WITH FRAME Dialog-Frame.
           ENABLE
           tt-dis-time-rule.week-day-3 WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
           WITH FRAME Dialog-Frame.
        END.
        else do:
          hide
          tt-dis-time-rule.week-day-3
          in FRAME Dialog-Frame.
        end.
        IF lookup("week-day-4":U, vt-level-1) >  0
        AND lookup("week-day-a":U, p-other, ";") = 0
        AND lookup("week-day-b":U, p-other, ";") = 0 THEN DO:
           DISPLAY
           tt-dis-time-rule.week-day-4
           WITH FRAME Dialog-Frame.
           ENABLE
           tt-dis-time-rule.week-day-4 WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
           WITH FRAME Dialog-Frame.
        END.
        else do:
          hide
          tt-dis-time-rule.week-day-4
          in FRAME Dialog-Frame.
        end.
        IF lookup("week-day-5":U, vt-level-1) >  0
        AND lookup("week-day-a":U, p-other, ";") = 0
        AND lookup("week-day-b":U, p-other, ";") = 0 THEN DO:
           DISPLAY
           tt-dis-time-rule.week-day-5
           WITH FRAME Dialog-Frame.
           ENABLE
           tt-dis-time-rule.week-day-5 WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
           WITH FRAME Dialog-Frame.
        END.
        else do:
          hide
          tt-dis-time-rule.week-day-5
          in FRAME Dialog-Frame.
        end.
        IF lookup("week-day-6":U, vt-level-1) >  0
        AND lookup("week-day-a":U, p-other, ";") = 0
        AND lookup("week-day-b":U, p-other, ";") = 0 THEN DO:
           DISPLAY
           tt-dis-time-rule.week-day-6
           WITH FRAME Dialog-Frame.
           ENABLE
           tt-dis-time-rule.week-day-6 WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
           WITH FRAME Dialog-Frame.
        END.
        else do:
          hide
          tt-dis-time-rule.week-day-6
          in FRAME Dialog-Frame.
        end.
        IF lookup("week-day-7":U, vt-level-1) >  0
        AND lookup("week-day-a":U, p-other, ";") = 0
        AND lookup("week-day-b":U, p-other, ";") = 0 THEN DO:
           DISPLAY
           tt-dis-time-rule.week-day-7
           WITH FRAME Dialog-Frame.
           ENABLE
           tt-dis-time-rule.week-day-7 WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
           WITH FRAME Dialog-Frame.
        END.
        else do:
          hide
          tt-dis-time-rule.week-day-7
          in FRAME Dialog-Frame.
        end.
        IF (lookup("week-day-0", vt-level-1) > 0
        or lookup("week-day-1", vt-level-1) > 0
        or lookup("week-day-2", vt-level-1) > 0
        or lookup("week-day-3", vt-level-1) > 0
        or lookup("week-day-4", vt-level-1) > 0
        or lookup("week-day-5", vt-level-1) > 0
        or lookup("week-day-6", vt-level-1) > 0
        or lookup("week-day-7", vt-level-1) > 0)
        AND lookup("week-day-c":U, p-tree) = 0
        AND lookup("week-day-a":U, p-tree) = 0
        AND lookup("week-day-b":U, p-tree) = 0
        AND lookup("week-day-c":U, p-other, ";") = 0 THEN DO:
           DISPLAY
           RS-week-day
           WITH FRAME Dialog-Frame.
           ENABLE
           RS-week-day WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
           WITH FRAME Dialog-Frame.
        END.
        else do:
          hide
          RS-week-day
          in FRAME Dialog-Frame.
        end.
        if rs-week-day:sensitive in frame Dialog-Frame then do:
          if lookup("week-day-0", vt-level-1) = 0 then do:
            if lookup("0", rs-week-day:radio-buttons) > 0 then
            rs-week-day:disable(radio-label(string(0), rs-week-day:radio-buttons)).
          end.
          if lookup("week-day-1", vt-level-1) = 0 then do:
            rs-week-day:disable(radio-label(string(1), rs-week-day:radio-buttons)).
          end.
          if lookup("week-day-2", vt-level-1) = 0 then do:
            rs-week-day:disable(radio-label(string(2), rs-week-day:radio-buttons)).
          end.
          if lookup("week-day-3", vt-level-1) = 0 then do:
            rs-week-day:disable(radio-label(string(3), rs-week-day:radio-buttons)).
          end.
          if lookup("week-day-4", vt-level-1) = 0 then do:
            rs-week-day:disable(radio-label(string(4), rs-week-day:radio-buttons)).
          end.
          if lookup("week-day-5", vt-level-1) = 0 then do:
            rs-week-day:disable(radio-label(string(5), rs-week-day:radio-buttons)).
          end.
          if lookup("week-day-6", vt-level-1) = 0 then do:
            rs-week-day:disable(radio-label(string(6), rs-week-day:radio-buttons)).
          end.
          if lookup("week-day-7", vt-level-1) = 0 then do:
            rs-week-day:disable(radio-label(string(7), rs-week-day:radio-buttons)).
          end.
        end.
      END.
      ELSE DO:
          IF lookup("time-period":U, vt-level-2) > 0
          OR lookup("time-period":U, p-tree) > 0
          THEN DO:
             DISPLAY
             fhour fmin fsec
             WITH FRAME Dialog-Frame.
             ENABLE
             fhour WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
             fmin WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
             fsec WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
             WITH FRAME Dialog-Frame.
          END.
          else do:
            hide
            fhour fmin fsec
            in FRAME Dialog-Frame.
          end.
          IF lookup("time-to":U, vt-level-2) > 0
          OR lookup("time-period":U, p-tree) > 0  THEN DO:
             DISPLAY
             thour tmin tsec
             WITH FRAME Dialog-Frame.
             ENABLE
             thour WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
             tmin WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
             tsec WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
             WITH FRAME Dialog-Frame.
          END.
          else do:
            hide
            thour tmin tsec
            in FRAME Dialog-Frame.
          end.
          IF lookup("date-from":U, vt-level-2) > 0
          OR lookup("date-period":U, p-tree) > 0 THEN DO:
             DISPLAY
             tt-dis-time-rule.date-from
             WITH FRAME Dialog-Frame.
             ENABLE
             tt-dis-time-rule.date-from WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
             WITH FRAME Dialog-Frame.
          END.
          else do:
            hide
            tt-dis-time-rule.date-from
            in FRAME Dialog-Frame.
          end.
          IF lookup("date-to":U, vt-level-2) > 0
          OR lookup("date-period":U, p-tree) > 0 THEN DO:
             DISPLAY
             tt-dis-time-rule.date-to
             WITH FRAME Dialog-Frame.
             ENABLE
             tt-dis-time-rule.date-to WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
             WITH FRAME Dialog-Frame.
          END.
          else do:
            hide
            tt-dis-time-rule.date-to
            in FRAME Dialog-Frame.
          end.
          IF lookup("month-day":U, vt-level-2) > 0  THEN DO:
             view
             tt-dis-time-rule.month-day
             in FRAME Dialog-Frame.
             ENABLE
             tt-dis-time-rule.month-day WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
             WITH FRAME Dialog-Frame.
          END.
          else do:
            hide
            tt-dis-time-rule.month-day
            in FRAME Dialog-Frame.
          end.
          IF (lookup("week-day-1":U, vt-level-2) > 0
          OR lookup("week-day-c":U, p-tree) > 0 )
          AND lookup("week-day-a":U, p-tree) = 0
          AND lookup("week-day-b":U, p-tree) = 0
          THEN DO:
             view
             tt-dis-time-rule.week-day-1
             in FRAME Dialog-Frame.
             ENABLE
             tt-dis-time-rule.week-day-1 WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
             WITH FRAME Dialog-Frame.
          END.
          else do:
            hide
            tt-dis-time-rule.week-day-1
            in FRAME Dialog-Frame.
          end.
          IF (lookup("week-day-2":U, vt-level-2) > 0
          OR lookup("week-day-c":U, p-tree) > 0 )
          AND lookup("week-day-a":U, p-tree) = 0
          AND lookup("week-day-b":U, p-tree) = 0
          THEN DO:
             view
             tt-dis-time-rule.week-day-2
             in FRAME Dialog-Frame.
             ENABLE
             tt-dis-time-rule.week-day-2 WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
             WITH FRAME Dialog-Frame.
          END.
          else do:
            hide
            tt-dis-time-rule.week-day-2
            in FRAME Dialog-Frame.
          end.
          IF (lookup("week-day-3":U, vt-level-2) > 0
          OR lookup("week-day-c":U, p-tree) > 0 )
          AND lookup("week-day-a":U, p-tree) = 0
          AND lookup("week-day-b":U, p-tree) = 0
          THEN DO:
             view
             tt-dis-time-rule.week-day-3
             in FRAME Dialog-Frame.
             ENABLE
             tt-dis-time-rule.week-day-3 WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
             WITH FRAME Dialog-Frame.
          END.
          else do:
            hide
            tt-dis-time-rule.week-day-3
            in FRAME Dialog-Frame.
          end.
          IF (lookup("week-day-4":U, vt-level-2) > 0
          OR lookup("week-day-c":U, p-tree) > 0)
          AND lookup("week-day-a":U, p-tree) = 0
          AND lookup("week-day-b":U, p-tree) = 0
          THEN DO:
             view
             tt-dis-time-rule.week-day-4
             In FRAME Dialog-Frame.
             enable
             tt-dis-time-rule.week-day-4 WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
             WITH FRAME Dialog-Frame.
          END.
          else do:
            hide
            tt-dis-time-rule.week-day-4
            in FRAME Dialog-Frame.
          end.
          IF (lookup("week-day-5":U, vt-level-2) > 0
          OR lookup("week-day-c":U, p-tree) > 0)
          AND lookup("week-day-a":U, p-tree) = 0
          AND lookup("week-day-b":U, p-tree) = 0
          THEN DO:
             view
             tt-dis-time-rule.week-day-5
             in FRAME Dialog-Frame.
             ENABLE
             tt-dis-time-rule.week-day-5 WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
             WITH FRAME Dialog-Frame.
          END.
          else do:
            hide
            tt-dis-time-rule.week-day-5
            in FRAME Dialog-Frame.
          end.
          IF (lookup("week-day-6":U, vt-level-2) > 0
          OR lookup("week-day-c":U, p-tree) > 0)
          AND lookup("week-day-a":U, p-tree) = 0
          AND lookup("week-day-b":U, p-tree) = 0
          THEN DO:
             view
             tt-dis-time-rule.week-day-6
             in FRAME Dialog-Frame.
             ENABLE
             tt-dis-time-rule.week-day-6 WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
             WITH FRAME Dialog-Frame.
          END.
          else do:
            hide
            tt-dis-time-rule.week-day-6
            in FRAME Dialog-Frame.
          end.
          IF (lookup("week-day-7":U, vt-level-2) > 0
          OR lookup("week-day-c":U, p-tree) > 0)
          AND lookup("week-day-a":U, p-tree) = 0
          AND lookup("week-day-b":U, p-tree) = 0
         THEN DO:
             view
             tt-dis-time-rule.week-day-7
             in FRAME Dialog-Frame.
             ENABLE
             tt-dis-time-rule.week-day-7 WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
             WITH FRAME Dialog-Frame.
          END.
          else do:
            hide
            tt-dis-time-rule.week-day-7
            in FRAME Dialog-Frame.
          end.
        IF (lookup("week-day-0":U, vt-level-2) > 0
        or lookup("week-day-1":U, vt-level-2) > 0
        or lookup("week-day-2":U, vt-level-2) > 0
        or lookup("week-day-3":U, vt-level-2) > 0
        or lookup("week-day-4":U, vt-level-2) > 0
        or lookup("week-day-5":U, vt-level-2) > 0
        or lookup("week-day-6":U, vt-level-2) > 0
        or lookup("week-day-7":U, vt-level-2) > 0
        )
        and lookup("week-day-c":U, p-tree) = 0
        AND (lookup("week-day-a":U, p-tree) > 0
        OR lookup("week-day-b":U, p-tree) > 0)
        AND lookup("week-day-c":U, p-other, ";") = 0 THEN DO:
           view
           RS-week-day
           in FRAME Dialog-Frame.
           ENABLE
           RS-week-day WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
           WITH FRAME Dialog-Frame.
        END.
        else do:
          hide
          RS-week-day
          in FRAME Dialog-Frame.
        end.
     END.
   END.
   WHEN 0 THEN DO:
       HIDE
       fhour fmin fsec
       thour tmin tsec
       RS-week-day
       tt-dis-time-rule.date-from
       tt-dis-time-rule.date-to
       tt-dis-time-rule.month-day
       tt-dis-time-rule.week-day-1
       tt-dis-time-rule.week-day-2
       tt-dis-time-rule.week-day-3
       tt-dis-time-rule.week-day-4
       tt-dis-time-rule.week-day-5
       tt-dis-time-rule.week-day-6
       tt-dis-time-rule.week-day-7
       in FRAME Dialog-Frame.
   END.
  END CASE.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-dis-time-rule SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY fhour fmin fsec thour tmin tsec RS-week-day lfromt ltot
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-dis-time-rule THEN
    DISPLAY tt-dis-time-rule.des tt-dis-time-rule.date-from
          tt-dis-time-rule.date-to tt-dis-time-rule.month-day
          tt-dis-time-rule.week-day-1 tt-dis-time-rule.week-day-2
          tt-dis-time-rule.week-day-3 tt-dis-time-rule.week-day-4
          tt-dis-time-rule.week-day-5 tt-dis-time-rule.week-day-6
          tt-dis-time-rule.week-day-7
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-hist B-Help tt-dis-time-rule.des B-add B-del
         tt-dis-time-rule.date-from br-term-dtr tt-dis-time-rule.date-to fhour
         fmin fsec thour tmin tsec tt-dis-time-rule.month-day
         tt-dis-time-rule.week-day-1 RS-week-day tt-dis-time-rule.week-day-2
         tt-dis-time-rule.week-day-3 tt-dis-time-rule.week-day-4
         tt-dis-time-rule.week-day-5 tt-dis-time-rule.week-day-6
         tt-dis-time-rule.week-day-7 B-exit-1 B-quit-1 lfromt ltot
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-tables :
define variable f-chr as character no-undo .
define variable t-chr as character no-undo .
DEFINE BUFFER buf_tt0-term_dis-time-rule FOR tt0-term_dis-time-rule.
DEFINE BUFFER buf_dis-time-rule FOR ub.dis-time-rule.
IF p-mode = 'ƒŒ¡¿¬À≈Õ»≈':U THEN RETURN.
FOR EACH buf_tt0-term_dis-time-rule:
    DELETE buf_tt0-term_dis-time-rule.
END.
if (lookup("time-from":U, vt-tree) = 0
AND lookup("time-period":U, vt-tree) = 0) then do:
  assign
  f-chr = string(tt-dis-time-rule.time-from, "HH:MM:SS")
  fhour = integer(substring(f-chr, 1, 2))
  fmin  = integer(substring(f-chr, 4, 2))
  fsec  = integer(substring(f-chr, 7, 2))
  .
end.
if (lookup("time-to":U, vt-tree) = 0
          AND lookup("time-period":U, vt-tree) = 0) then do:
  assign
  t-chr = string(tt-dis-time-rule.time-to, "HH:MM:SS")
  thour = integer(substring(t-chr, 1, 2))
  tmin  = integer(substring(t-chr, 4, 2))
  tsec  = integer(substring(t-chr, 7, 2))
  .
end.
IF lookup("week-day-0", vt-level-1) > 0
OR lookup("week-day-1", vt-level-1) > 0
OR lookup("week-day-2", vt-level-1) > 0
OR lookup("week-day-3", vt-level-1) > 0
OR lookup("week-day-4", vt-level-1) > 0
OR lookup("week-day-5", vt-level-1) > 0
OR lookup("week-day-6", vt-level-1) > 0
OR lookup("week-day-7", vt-level-1) > 0
AND lookup("week-day-c":U, vt-tree) = 0
AND lookup("week-day-a":U, vt-tree) = 0
AND lookup("week-day-b":U, vt-tree) = 0
AND lookup("week-day-c":U, vt-other, ";") = 0 THEN DO:
  if tt-dis-time-rule.week-day-0 then
  RS-week-day = 0.
  if tt-dis-time-rule.week-day-1 then
  RS-week-day = 1.
  if tt-dis-time-rule.week-day-2 then
  RS-week-day = 2.
  if tt-dis-time-rule.week-day-3 then
  RS-week-day = 3.
  if tt-dis-time-rule.week-day-4 then
  RS-week-day = 4.
  if tt-dis-time-rule.week-day-5 then
  RS-week-day = 5.
  if tt-dis-time-rule.week-day-6 then
  RS-week-day = 6.
  if tt-dis-time-rule.week-day-7 then
  RS-week-day = 7.
end.
FOR EACH buf_dis-time-rule NO-LOCK WHERE
        buf_dis-time-rule.upper-time-rule-num = tt-dis-time-rule.time-rule-num:
  CREATE buf_tt0-term_dis-time-rule.
  BUFFER-COPY buf_dis-time-rule
  TO buf_tt0-term_dis-time-rule
  ASSIGN
  buf_tt0-term_dis-time-rule.time-from = (IF lookup("time-from":U, vt-level-2) = 0
                                          AND lookup("time-period":U, vt-level-2) = 0
                                    THEN 0
                                    ELSE buf_dis-time-rule.time-from)
  buf_tt0-term_dis-time-rule.time-to = (IF lookup("time-to":U, vt-level-2) = 0
                                              AND lookup("time-period":U, vt-level-2) = 0
                                        THEN 0
                                        ELSE buf_dis-time-rule.time-to)
  buf_tt0-term_dis-time-rule.date-from = (IF lookup("date-from":U, vt-level-2) = 0
                                          AND lookup("date-period":U, vt-level-2) = 0
                                    THEN 01/01/1990
                                    ELSE buf_dis-time-rule.date-from)
  buf_tt0-term_dis-time-rule.date-to = (IF lookup("date-to":U, vt-level-2) = 0
                                              AND lookup("date-period":U, vt-level-2) = 0
                                        THEN 01/01/1990
                                        ELSE buf_dis-time-rule.date-to)
  buf_tt0-term_dis-time-rule.month-day = (IF lookup("month-day":U, vt-level-2) = 0
                                           THEN 0
                                   ELSE buf_dis-time-rule.month-day)
  buf_tt0-term_dis-time-rule.week-day-0 = (IF lookup("week-day-0":U, vt-level-2) = 0
                                          AND lookup("week-day-a":U, vt-level-2) = 0
                                    THEN FALSE
                                    ELSE buf_dis-time-rule.week-day-0)
  buf_tt0-term_dis-time-rule.week-day-1 = (IF lookup("week-day-0":U, vt-level-2) = 0
                                          AND lookup("week-day-a":U, vt-level-2) = 0
                                          AND lookup("week-day-b":U, vt-level-2) = 0
                                          AND lookup("week-day-c":U, vt-level-2) = 0
                                    THEN FALSE
                                    ELSE buf_dis-time-rule.week-day-1)
  buf_tt0-term_dis-time-rule.week-day-2 = (IF lookup("week-day-0":U, vt-level-2) = 0
                                          AND lookup("week-day-a":U, vt-level-2) = 0
                                          AND lookup("week-day-b":U, vt-level-2) = 0
                                          AND lookup("week-day-c":U, vt-level-2) = 0
                                    THEN FALSE
                                    ELSE buf_dis-time-rule.week-day-2)
  buf_tt0-term_dis-time-rule.week-day-3 = (IF lookup("week-day-0":U, vt-level-2) = 0
                                            AND lookup("week-day-a":U, vt-level-2) = 0
                                            AND lookup("week-day-b":U, vt-level-2) = 0
                                            AND lookup("week-day-c":U, vt-level-2) = 0
                                      THEN FALSE
                                      ELSE buf_dis-time-rule.week-day-3)
  buf_tt0-term_dis-time-rule.week-day-4 = (IF lookup("week-day-0":U, vt-level-2) = 0
                                            AND lookup("week-day-a":U, vt-level-2) = 0
                                            AND lookup("week-day-b":U, vt-level-2) = 0
                                            AND lookup("week-day-c":U, vt-level-2) = 0
                                      THEN FALSE
                                      ELSE buf_dis-time-rule.week-day-4)
  buf_tt0-term_dis-time-rule.week-day-5 = (IF lookup("week-day-0":U, vt-level-2) = 0
                                            AND lookup("week-day-a":U, vt-level-2) = 0
                                            AND lookup("week-day-b":U, vt-level-2) = 0
                                            AND lookup("week-day-c":U, vt-level-2) = 0
                                      THEN FALSE
                                      ELSE buf_dis-time-rule.week-day-5)
  buf_tt0-term_dis-time-rule.week-day-6 = (IF lookup("week-day-0":U, vt-level-2) = 0
                                            AND lookup("week-day-a":U, vt-level-2) = 0
                                            AND lookup("week-day-b":U, vt-level-2) = 0
                                            AND lookup("week-day-c":U, vt-level-2) = 0
                                      THEN FALSE
                                      ELSE buf_dis-time-rule.week-day-6)
  buf_tt0-term_dis-time-rule.week-day-7 = (IF lookup("week-day-0":U, vt-level-2) = 0
                                            AND lookup("week-day-a":U, vt-level-2) = 0
                                            AND lookup("week-day-b":U, vt-level-2) = 0
                                            AND lookup("week-day-c":U, vt-level-2) = 0
                                      THEN FALSE
                                      ELSE buf_dis-time-rule.week-day-7)
  .
END.
END PROCEDURE.
PROCEDURE MyEnable :
define variable ii AS INTEGER NO-UNDO.
ASSIGN
v-tab-order = "des,b-add,b-del,date-from,date-to,fhour,fmin,fsec,thour,tmin,tsec,month-day" +
              "week-day-1,week-day-2,week-day-3,week-day-4,week-day-5,week-day-6,week-day-7,RS-week-day," +
              "b-exit-1,b-quit-1"
FRAME Dialog-Frame:TITLE = substitute("&1 &2 &3"
                                      , (if p-mode = 'ƒŒ¡¿¬À≈Õ»≈':U then '' else string(p-time-rule-num))
                                      , FRAME Dialog-Frame:TITLE
                                      , vt-des
                                      )
.
IF LOOKUP("week-day-b", vt-tree) > 0
OR LOOKUP("week-day-b", vt-other, ";") > 0 THEN DO:
  define variable kkk as character no-undo .
  kkk = rs-week-day:RADIO-BUTTONS.
  kkk = substring(kkk, 1, R-INDEX(kkk, chr(44)) - 1).
  kkk = substring(kkk, 1, R-INDEX(kkk, chr(44)) - 1).
  ASSIGN
  rs-week-day:RADIO-BUTTONS = kkk
  .
END.
RUN display-hide-fields IN THIS-PROCEDURE ( vt-tree, vt-other, YES , 1 ).
IF vt-tree = "":U THEN DO:
  HIDE
  br-term-dtr
  b-exit-1
  b-quit-1
  b-add
  b-del
  in FRAME Dialog-Frame.
END.
ELSE DO:
DO ii = 1 TO NUM-ENTRIES(vt-tree):
    ASSIGN
    v-display-time-from:VISIBLE IN BROWSE br-term-dtr = no
    v-display-time-to:VISIBLE IN BROWSE br-term-dtr = no
    .
    case ENTRY(ii, vt-tree):
        WHEN "date-from":U THEN DO:
            ASSIGN
            tt0-term_dis-time-rule.date-from:VISIBLE IN BROWSE br-term-dtr = YES
             .
        END.
        WHEN "date-to":U THEN DO:
            ASSIGN
            tt0-term_dis-time-rule.date-to:VISIBLE IN BROWSE br-term-dtr = YES
            .
        END.
        WHEN "date-period":U THEN DO:
            ASSIGN
            tt0-term_dis-time-rule.date-from:VISIBLE IN BROWSE br-term-dtr = YES
            tt0-term_dis-time-rule.date-to:VISIBLE IN BROWSE br-term-dtr = YES
            .
        END.
        WHEN "time-from":U THEN DO:
            ASSIGN
            v-display-time-from:VISIBLE IN BROWSE br-term-dtr = YES
             .
        END.
        WHEN "time-to":U THEN DO:
            ASSIGN
            v-display-time-to:VISIBLE IN BROWSE br-term-dtr = YES
            .
        END.
        WHEN "time-period":U THEN DO:
            ASSIGN
            v-display-time-from:VISIBLE IN BROWSE br-term-dtr = YES
            v-display-time-to:VISIBLE IN BROWSE br-term-dtr = YES
            .
        END.
        WHEN "month-day":U THEN DO:
            ASSIGN
            tt0-term_dis-time-rule.month-day:VISIBLE IN BROWSE br-term-dtr = YES
            .
        END.
        WHEN "week-day-0" THEN DO:
            ASSIGN
            tt0-term_dis-time-rule.week-day-0:VISIBLE IN BROWSE br-term-dtr = YES
            .
       END.
        WHEN "week-day-a" THEN DO:
          ASSIGN
          tt0-term_dis-time-rule.week-day-0:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-1:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-2:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-3:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-4:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-5:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-6:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-7:VISIBLE IN BROWSE br-term-dtr = YES
          .
        END.
        WHEN "week-day-b" THEN DO:
          ASSIGN
          tt0-term_dis-time-rule.week-day-1:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-2:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-3:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-4:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-5:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-6:VISIBLE IN BROWSE br-term-dtr = YES
          tt0-term_dis-time-rule.week-day-7:VISIBLE IN BROWSE br-term-dtr = YES
          .
        END.
        WHEN "week-day-1"  THEN DO:
            ASSIGN
            tt0-term_dis-time-rule.week-day-1:VISIBLE IN BROWSE br-term-dtr = YES
            .
        END.
        WHEN "week-day-2"  THEN DO:
        ASSIGN
        tt0-term_dis-time-rule.week-day-2:VISIBLE IN BROWSE br-term-dtr = YES
        .
   END.
    WHEN "week-day-3" THEN DO:
        ASSIGN
        tt0-term_dis-time-rule.week-day-3:VISIBLE IN BROWSE br-term-dtr = YES
        .
   END.
        WHEN "week-day-4"  THEN DO:
            ASSIGN
            tt0-term_dis-time-rule.week-day-4:VISIBLE IN BROWSE br-term-dtr = YES
            .
       END.
        WHEN "week-day-5" THEN DO:
            ASSIGN
            tt0-term_dis-time-rule.week-day-5:VISIBLE IN BROWSE br-term-dtr = YES
            .
       END.
        WHEN "week-day-6"  THEN DO:
            ASSIGN
            tt0-term_dis-time-rule.week-day-6:VISIBLE IN BROWSE br-term-dtr = YES
            .
       END.
        WHEN "week-day-7"  THEN DO:
            ASSIGN
            tt0-term_dis-time-rule.week-day-7:VISIBLE IN BROWSE br-term-dtr = YES
            .
       END.
     END CASE.
    END.
    ENABLE
    b-add WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
    b-DEL WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
    WITH FRAME Dialog-Frame.
END.
IF AVAILABLE tt-dis-time-rule THEN
DISPLAY
tt-dis-time-rule.des
WITH FRAME Dialog-Frame.
IF (LOOKUP("week-day-a":U, vt-other) > 0 and LOOKUP("week-day-b":U, vt-other) > 0) THEN HIDE
rs-week-day  IN FRAME Dialog-Frame.
ENABLE
b-quit
B-exit WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
b-hist when p-mode <> 'ƒŒ¡¿¬À≈Õ»≈':U
B-Help
tt-dis-time-rule.des WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
WITH FRAME Dialog-Frame.
if p-mode <> 'œ–Œ—ÃŒ“–':U then do:
end.
VIEW FRAME Dialog-Frame.
IF p-mode = 'œ–Œ—ÃŒ“–':U THEN DO:
    HIDE
    b-exit
    IN FRAME Dialog-Frame.
    ASSIGN
    b-quit:LABEL = "&¬˚ıÓ‰"
    .
END.
IF vt-tree <> "":u THEN DO:
  ENABLE
  br-term-dtr
  WITH FRAME Dialog-Frame.
  RUN openbr-term-dtr.
  IF p-mode = 'œ–Œ—ÃŒ“–':U THEN APPLY "ENTRY" TO b-exit.
  ELSE APPLY "entry" to b-add.
END.
ELSE DO:
END.
END PROCEDURE.
PROCEDURE openbr-term-dtr :
OPEN QUERY BR-term-dtr
  FOR  EACH tt0-term_dis-time-rule WHERE
           tt0-term_dis-time-rule.upper-time-rule-num = tt-dis-time-rule.time-rule-num
BY tt0-term_dis-time-rule.date-from
BY tt0-term_dis-time-rule.date-to
BY tt0-term_dis-time-rule.time-from
BY tt0-term_dis-time-rule.time-to
BY tt0-term_dis-time-rule.week-day-0
BY tt0-term_dis-time-rule.week-day-1
BY tt0-term_dis-time-rule.week-day-2
BY tt0-term_dis-time-rule.week-day-3
BY tt0-term_dis-time-rule.week-day-4
BY tt0-term_dis-time-rule.week-day-5
BY tt0-term_dis-time-rule.week-day-6
BY tt0-term_dis-time-rule.week-day-7
BY tt0-term_dis-time-rule.month-day
 .
END PROCEDURE.
PROCEDURE proc-b-add :
IF vt-tree = "":U THEN RETURN ERROR.
RUN display-hide-fields IN THIS-PROCEDURE ( vt-tree, vt-other, NO , 1 ).
IF lookup("date-from", vt-level-2) > 0
AND tt-dis-time-rule.date-from:sensitive  IN FRAME Dialog-Frame THEN DO:
   DISPLAY
   today @ tt-dis-time-rule.date-from
   WITH FRAME Dialog-Frame.
END.
IF lookup("date-to", vt-level-2) > 0
AND tt-dis-time-rule.date-to:sensitive  IN FRAME Dialog-Frame THEN DO:
   DISPLAY
   today @ tt-dis-time-rule.date-to
   WITH FRAME Dialog-Frame.
END.
IF lookup("time-from", vt-level-2) > 0
AND fhour:sensitive  IN FRAME Dialog-Frame THEN DO:
   DISPLAY
   0 @ fhour
   0 @ fmin
   0 @ fsec
   WITH FRAME Dialog-Frame.
END.
IF lookup("time-to", vt-level-2) > 0
AND fhour:sensitive  IN FRAME Dialog-Frame THEN DO:
   DISPLAY
   0 @ thour
   0 @ tmin
   0 @ tsec
   WITH FRAME Dialog-Frame.
END.
IF lookup("month-day", vt-level-2) > 0
AND tt-dis-time-rule.month-day:sensitive  IN FRAME Dialog-Frame THEN DO:
   DISPLAY
   1 @ tt-dis-time-rule.month-day
   WITH FRAME Dialog-Frame.
END.
IF lookup("week-day-1", vt-level-2) > 0
AND tt-dis-time-rule.week-day-1:SENSITIVE IN FRAME Dialog-Frame THEN DO:
  ASSIGN
  tt-dis-time-rule.week-day-1:SCREEN-VALUE IN FRAME Dialog-Frame = "no".
  DISPLAY
  tt-dis-time-rule.week-day-1
  WITH FRAME Dialog-Frame.
END.
IF lookup("week-day-2", vt-level-2) > 0
AND tt-dis-time-rule.week-day-2:SENSITIVE IN FRAME Dialog-Frame THEN DO:
  ASSIGN
  tt-dis-time-rule.week-day-2:SCREEN-VALUE IN FRAME Dialog-Frame = "no".
  DISPLAY
  tt-dis-time-rule.week-day-2
  WITH FRAME Dialog-Frame.
END.
IF lookup("week-day-3", vt-level-2) > 0
AND tt-dis-time-rule.week-day-3:SENSITIVE IN FRAME Dialog-Frame THEN DO:
  ASSIGN
  tt-dis-time-rule.week-day-3:SCREEN-VALUE IN FRAME Dialog-Frame = "no".
  DISPLAY
  tt-dis-time-rule.week-day-3
  WITH FRAME Dialog-Frame.
END.
IF lookup("week-day-4", vt-level-2) > 0
AND tt-dis-time-rule.week-day-4:SENSITIVE IN FRAME Dialog-Frame THEN DO:
  ASSIGN
  tt-dis-time-rule.week-day-4:SCREEN-VALUE IN FRAME Dialog-Frame = "no".
  DISPLAY
  tt-dis-time-rule.week-day-4
  WITH FRAME Dialog-Frame.
END.
IF lookup("week-day-5", vt-level-2) > 0
AND tt-dis-time-rule.week-day-5:SENSITIVE IN FRAME Dialog-Frame THEN DO:
  ASSIGN
  tt-dis-time-rule.week-day-5:SCREEN-VALUE IN FRAME Dialog-Frame = "no".
  DISPLAY
  tt-dis-time-rule.week-day-5
  WITH FRAME Dialog-Frame.
END.
IF lookup("week-day-6", vt-level-2) > 0
AND tt-dis-time-rule.week-day-6:SENSITIVE IN FRAME Dialog-Frame THEN DO:
  ASSIGN
  tt-dis-time-rule.week-day-6:SCREEN-VALUE IN FRAME Dialog-Frame = "no".
  DISPLAY
  tt-dis-time-rule.week-day-6
  WITH FRAME Dialog-Frame.
END.
IF lookup("week-day-7", vt-level-2) > 0
AND tt-dis-time-rule.week-day-7:SENSITIVE IN FRAME Dialog-Frame THEN DO:
  ASSIGN
  tt-dis-time-rule.week-day-7:SCREEN-VALUE IN FRAME Dialog-Frame = "no".
  DISPLAY
  tt-dis-time-rule.week-day-7
  WITH FRAME Dialog-Frame.
END.
IF (lookup("week-day-0", vt-level-2) > 0
or lookup("week-day-1", vt-level-2) > 0
or lookup("week-day-2", vt-level-2) > 0
or lookup("week-day-3", vt-level-2) > 0
or lookup("week-day-4", vt-level-2) > 0
or lookup("week-day-5", vt-level-2) > 0
or lookup("week-day-6", vt-level-2) > 0
or lookup("week-day-7", vt-level-2) > 0
) AND RS-week-day:SENSITIVE IN FRAME Dialog-Frame THEN DO:
    ASSIGN
    RS-Week-day = 1.
    DISPLAY Rs-week-day
    WITH FRAME Dialog-Frame.
END.
ENABLE
b-exit-1
b-quit-1
WITH FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-del :
DEFINE BUFFER buf_tt0-term_dis-time-rule FOR tt0-term_dis-time-rule.
IF vt-tree = "":U THEN RETURN ERROR.
IF NOT AVAILABLE tt0-term_dis-time-rule THEN RETURN.
FIND first buf_tt0-term_dis-time-rule WHERE RECID(buf_tt0-term_dis-time-rule) = RECID(tt0-term_dis-time-rule).
DELETE buf_tt0-term_dis-time-rule.
RUN rename-term_dis-time-rule.
RUN openbr-term-dtr.
END PROCEDURE.
PROCEDURE proc-b-exit-1 :
DEFINE VARIABLE v-time-from LIKE ub.dis-time-rule.time-from NO-UNDO.
DEFINE VARIABLE v-time-to  LIKE ub.dis-time-rule.time-to NO-UNDO.
DEFINE VARIABLE v-date-from LIKE ub.dis-time-rule.date-from NO-UNDO.
DEFINE VARIABLE v-date-to  LIKE ub.dis-time-rule.date-to NO-UNDO.
DEFINE VARIABLE v-month-day  LIKE ub.dis-time-rule.month-day NO-UNDO.
DEFINE VARIABLE v-week-day-0  LIKE ub.dis-time-rule.week-day-0 NO-UNDO.
DEFINE VARIABLE v-week-day-1  LIKE ub.dis-time-rule.week-day-1 NO-UNDO.
DEFINE VARIABLE v-week-day-2  LIKE ub.dis-time-rule.week-day-2 NO-UNDO.
DEFINE VARIABLE v-week-day-3  LIKE ub.dis-time-rule.week-day-3 NO-UNDO.
DEFINE VARIABLE v-week-day-4  LIKE ub.dis-time-rule.week-day-4 NO-UNDO.
DEFINE VARIABLE v-week-day-5  LIKE ub.dis-time-rule.week-day-5 NO-UNDO.
DEFINE VARIABLE v-week-day-6  LIKE ub.dis-time-rule.week-day-6 NO-UNDO.
DEFINE VARIABLE v-week-day-7  LIKE ub.dis-time-rule.week-day-7 NO-UNDO.
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-time-rule-num LIKE ub.dis-time-rule.time-rule-num NO-UNDO.
DEFINE VARIABLE v-dub AS LOGICAL NO-UNDO.
DEFINE BUFFER buf_tt0-term_dis-time-rule FOR tt0-term_dis-time-rule.
IF vt-tree = "":U  THEN RETURN ERROR.
ASSIGN
v-date-from = tt-dis-time-rule.date-from
v-date-to = tt-dis-time-rule.date-to
v-month-day = tt-dis-time-rule.month-day
v-time-from = tt-dis-time-rule.time-from
v-time-to = tt-dis-time-rule.time-to
v-week-day-0 = tt-dis-time-rule.week-day-0
v-week-day-1 = tt-dis-time-rule.week-day-1
v-week-day-2 = tt-dis-time-rule.week-day-2
v-week-day-3 = tt-dis-time-rule.week-day-3
v-week-day-4 = tt-dis-time-rule.week-day-4
v-week-day-5 = tt-dis-time-rule.week-day-5
v-week-day-6 = tt-dis-time-rule.week-day-6
v-week-day-7 = tt-dis-time-rule.week-day-7
.
IF tt-dis-time-rule.date-from:SENSITIVE IN FRAME Dialog-Frame THEN DO:
  ASSIGN
  v-date-from = INPUT FRAME Dialog-Frame tt-dis-time-rule.date-from
  .
END.
IF tt-dis-time-rule.date-to:SENSITIVE IN FRAME Dialog-Frame THEN DO:
  ASSIGN
  v-date-to = INPUT FRAME Dialog-Frame tt-dis-time-rule.date-to
  .
END.
IF fhour:SENSITIVE IN FRAME Dialog-Frame THEN DO:
  ASSIGN
  fhour
  fmin
  fsec
  v-time-from = fhour * 3600 + fmin * 60 + fsec
  .
END.
IF thour:SENSITIVE IN FRAME Dialog-Frame THEN DO:
  ASSIGN
  thour
  tmin
  tsec
  v-time-to = thour * 3600 + tmin * 60 + tsec
  .
END.
IF tt-dis-time-rule.month-day:SENSITIVE IN FRAME Dialog-Frame THEN DO:
  ASSIGN
  v-month-day = INPUT FRAME Dialog-Frame tt-dis-time-rule.month-day
  .
END.
IF RS-week-day:sensitive IN FRAME Dialog-Frame THEN DO:
    ASSIGN
    RS-week-day
    v-week-day-0 = (IF rs-week-day = 0 THEN YES ELSE v-week-day-0)
    v-week-day-1 = (IF rs-week-day = 1 THEN YES ELSE v-week-day-1)
    v-week-day-2 = (IF rs-week-day = 2 THEN YES ELSE v-week-day-2)
    v-week-day-3 = (IF rs-week-day = 3 THEN YES ELSE v-week-day-3)
    v-week-day-4 = (IF rs-week-day = 4 THEN YES ELSE v-week-day-4)
    v-week-day-5 = (IF rs-week-day = 5 THEN YES ELSE v-week-day-5)
    v-week-day-6 = (IF rs-week-day = 6 THEN YES ELSE v-week-day-6)
    v-week-day-7 = (IF rs-week-day = 7 THEN YES ELSE v-week-day-7)
    .
END.
IF tt-dis-time-rule.week-day-1:SENSITIVE IN  FRAME Dialog-Frame THEN DO:
    ASSIGN
    v-week-day-1 = tt-dis-time-rule.week-day-1
    .
END.
IF tt-dis-time-rule.week-day-2:SENSITIVE IN  FRAME Dialog-Frame THEN DO:
    ASSIGN
    v-week-day-2 = tt-dis-time-rule.week-day-2
    .
END.
IF tt-dis-time-rule.week-day-3:SENSITIVE IN FRAME Dialog-Frame THEN DO:
    ASSIGN
    v-week-day-3 = tt-dis-time-rule.week-day-3
    .
END.
IF tt-dis-time-rule.week-day-4:SENSITIVE IN FRAME Dialog-Frame THEN DO:
    ASSIGN
    v-week-day-4 = tt-dis-time-rule.week-day-4
    .
END.
IF tt-dis-time-rule.week-day-5:SENSITIVE IN FRAME Dialog-Frame THEN DO:
    ASSIGN
    v-week-day-5 = tt-dis-time-rule.week-day-5
    .
END.
IF tt-dis-time-rule.week-day-6:SENSITIVE IN FRAME Dialog-Frame THEN DO:
    ASSIGN
    v-week-day-6 = tt-dis-time-rule.week-day-6
    .
END.
IF tt-dis-time-rule.week-day-7:SENSITIVE IN FRAME Dialog-Frame THEN DO:
    ASSIGN
    v-week-day-7 = tt-dis-time-rule.week-day-7
    .
END.
_dub:
FOR EACH buf_tt0-term_dis-time-rule WHERE
        buf_tt0-term_dis-time-rule.upper-time-rule-num = tt-dis-time-rule.time-rule-num:
  ASSIGN
  v-time-rule-num = max(buf_tt0-term_dis-time-rule.time-rule-num, v-time-rule-num)
  .
    if lookup("time-from", vt-level-2) > 0
    and lookup("time-from":U, vt-tree) > 0
    AND lookup("time-period":U, vt-tree) = 0
    AND lookup("date-period":U, vt-tree) = 0
    AND buf_tt0-term_dis-time-rule.time-from = v-time-from then do:
        assign
        v-dub = yes
        .
        MESSAGE
        substitute("”ÊÂ ÂÒÚ¸ –¿—œ»—¿Õ»≈ ‰Îˇ Ú‡ÍÓ„Ó Ì‡˜‡Î‡ ÔÂËÓ‰‡ ‚ÂÏÂÌË &1", string(v-time-from, "hh:mm:ss"))
        VIEW-AS ALERT-BOX.
        LEAVE _dub.
    end.
    if lookup("time-to", vt-level-2) > 0
    and lookup("time-to":U, vt-tree) > 0
    AND lookup("time-period":U, vt-tree) = 0
    AND lookup("date-period":U, vt-tree) = 0
    AND buf_tt0-term_dis-time-rule.time-to = v-time-to then do:
        assign
        v-dub = yes
        .
        MESSAGE
        substitute("”ÊÂ ÂÒÚ¸ –¿—œ»—¿Õ»≈ ‰Îˇ Ú‡ÍÓ„Ó ÍÓÌˆ‡ ÔÂËÓ‰‡ ‚ÂÏÂÌË &1", string(v-time-to, "hh:mm:ss":U))
        VIEW-AS ALERT-BOX.
        LEAVE _dub.
    end.
    IF lookup("time-period":U, vt-tree) > 0 then do:
       if lookup("week-day-a":U, vt-tree) > 0
       and not (v-week-day-0 = buf_tt0-term_dis-time-rule.week-day-0
           and  v-week-day-1 = buf_tt0-term_dis-time-rule.week-day-1
           and  v-week-day-2 = buf_tt0-term_dis-time-rule.week-day-2
           and  v-week-day-3 = buf_tt0-term_dis-time-rule.week-day-3
           and  v-week-day-4 = buf_tt0-term_dis-time-rule.week-day-4
           and  v-week-day-5 = buf_tt0-term_dis-time-rule.week-day-5
           and  v-week-day-6 = buf_tt0-term_dis-time-rule.week-day-6
           and  v-week-day-7 = buf_tt0-term_dis-time-rule.week-day-7) then.
       else DO:
        IF (v-time-from <=  buf_tt0-term_dis-time-rule.time-from
            AND
            v-time-to >=  buf_tt0-term_dis-time-rule.time-to )
        OR (v-time-from >=  buf_tt0-term_dis-time-rule.time-from
            AND
            v-time-from <=  buf_tt0-term_dis-time-rule.time-to )
        OR (v-time-to >= buf_tt0-term_dis-time-rule.time-from
            AND
            v-time-to <=  buf_tt0-term_dis-time-rule.time-to ) THEN DO:
          assign
          v-dub = yes
          .
          MESSAGE
          substitute("≈ÒÚ¸ –¿—œ»—¿Õ»≈ ÔÂÂÒÂÍ‡˛˘ÂÂÒˇ Ò ‰‡ÌÌ˚Ï ÔÂËÓ‰ÓÏ ‚ÂÏÂÌË &1-&2"
                      , string(v-time-from, "hh:mm:ss")
                      , string(v-time-to, "hh:mm:ss"))
          VIEW-AS ALERT-BOX.
          LEAVE _dub.
        end.
      end.
    END.
    if lookup("date-from", vt-level-2) > 0
    and lookup("date-from":U, vt-tree) > 0
    AND lookup("date-period":U, vt-tree) = 0
    AND buf_tt0-term_dis-time-rule.date-from = v-date-from then do:
        assign
        v-dub = yes
        .
        MESSAGE
        substitute("”ÊÂ ÂÒÚ¸ –¿—œ»—¿Õ»≈ ‰Îˇ Ú‡ÍÓ„Ó Ì‡˜‡Î‡ ÔÂËÓ‰‡ ‰‡Ú &1", v-date-from)
        VIEW-AS ALERT-BOX.
        LEAVE _dub.
    end.
    if lookup("date-to", vt-level-2) > 0
    and lookup("date-to":U, vt-tree) > 0
    AND lookup("date-period":U, vt-tree) = 0
    AND buf_tt0-term_dis-time-rule.date-to = v-date-to then do:
        assign
        v-dub = yes
        .
        MESSAGE
        substitute("”ÊÂ ÂÒÚ¸ –¿—œ»—¿Õ»≈ ‰Îˇ Ú‡ÍÓ„Ó ÍÓÌˆ‡ ÔÂËÓ‰‡ ‰‡Ú &1", v-date-from)
        VIEW-AS ALERT-BOX.
        LEAVE _dub.
    end.
    IF lookup("date-to", vt-level-2) > 0
    AND lookup("date-from", vt-level-2) > 0
    AND lookup("date-period":U, vt-tree) > 0  THEN DO:
        IF (v-date-from <=  buf_tt0-term_dis-time-rule.date-from
           AND
           v-date-to >=  buf_tt0-term_dis-time-rule.date-to )
        OR (v-date-from >=  buf_tt0-term_dis-time-rule.date-from
            AND
            v-date-to >=  buf_tt0-term_dis-time-rule.date-to )
        OR (v-date-from >= buf_tt0-term_dis-time-rule.date-to
            AND
            v-date-to <=  buf_tt0-term_dis-time-rule.date-to ) THEN DO:
        END.
        assign
        v-dub = yes
        .
        MESSAGE
        substitute("≈ÒÚ¸ –¿—œ»—¿Õ»≈ ÔÂÂÒÂÍ‡˛˘ÂÂÒˇ Ò ‰‡ÌÌ˚Ï ÔÂËÓ‰ÓÏ ‰‡Ú &1:&2"
                   , string(v-date-from)
                   , string(v-date-to))
        VIEW-AS ALERT-BOX.
        LEAVE _dub.
    END.
END.
IF v-dub THEN UNDO, RETURN ERROR.
CREATE buf_tt0-term_dis-time-rule.
BUFFER-COPY tt-dis-time-rule
EXCEPT time-rule-num
    upper-time-rule-num des
    lvl-num
    is-term
    root
TO buf_tt0-term_dis-time-rule
ASSIGN
buf_tt0-term_dis-time-rule.time-rule-num = v-time-rule-num + 1
buf_tt0-term_dis-time-rule.upper-time-rule-num = tt-dis-time-rule.time-rule-num
buf_tt0-term_dis-time-rule.date-from = (IF lookup("date-from", vt-level-2) = 0
                                        THEN 12/31/1989
                                        ELSE v-date-from)
buf_tt0-term_dis-time-rule.date-to = (IF lookup("date-to", vt-level-2) = 0
                                       THEN 12/31/1989
                                       ELSE v-date-to)
buf_tt0-term_dis-time-rule.time-from = (IF lookup("time-from", vt-level-2) = 0
                                        THEN 0
                                        ELSE v-time-from)
buf_tt0-term_dis-time-rule.time-to = (IF lookup("time-to", vt-level-2) = 0
                                      THEN 0
                                      ELSE v-time-to)
buf_tt0-term_dis-time-rule.month-day = (IF lookup("month-day", vt-level-2) = 0
                                        THEN 0
                                        ELSE v-month-day)
buf_tt0-term_dis-time-rule.week-day-0 = (IF lookup("week-day-0", vt-level-2) = 0
                                         tHEN NO
                                         ELSE v-week-day-0)
buf_tt0-term_dis-time-rule.week-day-1 = (IF lookup("week-day-1", vt-level-2) = 0
                                        THEN NO
                                        ELSE v-week-day-1)
buf_tt0-term_dis-time-rule.week-day-2 = (IF lookup("week-day-2", vt-level-2) = 0
                                         THEN NO
                                         ELSE v-week-day-2)
buf_tt0-term_dis-time-rule.week-day-3 = (IF lookup("week-day-3", vt-level-2) = 0
                                         THEN NO
                                         ELSE v-week-day-3)
buf_tt0-term_dis-time-rule.week-day-4 = (IF lookup("week-day-4", vt-level-2) = 0
                                         THEN NO
                                         ELSE v-week-day-4)
buf_tt0-term_dis-time-rule.week-day-5 = (IF lookup("week-day-5", vt-level-2) = 0
                                         THEN NO
                                         ELSE v-week-day-5)
buf_tt0-term_dis-time-rule.week-day-6 = (IF lookup("week-day-6", vt-level-2) = 0
                                         THEN NO
                                         ELSE v-week-day-6)
buf_tt0-term_dis-time-rule.week-day-7 = (IF lookup("week-day-7", vt-level-2) = 0
                                         THEN NO
                                         ELSE v-week-day-7)
buf_tt0-term_dis-time-rule.sts   = INTEGER('2':U)
buf_tt0-term_dis-time-rule.root   = no
buf_tt0-term_dis-time-rule.is-term   = yes
buf_tt0-term_dis-time-rule.lvl-num   = tt-dis-time-rule.lvl-num + 1
.
RELEASE buf_tt0-term_dis-time-rule.
RUN display-hide-fields IN THIS-PROCEDURE(vt-tree, vt-other, NO, 0).
HIDE
b-exit-1
IN FRAME Dialog-Frame
b-quit-1
IN FRAME Dialog-Frame.
RUN rename-term_dis-time-rule.
RUN openbr-term-dtr.
END PROCEDURE.
PROCEDURE proc-b-quit-1 :
RUN display-hide-fields IN THIS-PROCEDURE ( vt-tree, vt-other, NO , 0 ).
HIDE
b-exit-1
IN FRAME Dialog-Frame
b-quit-1
IN FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-log AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-dub-time-rule-num LIKE ub.dis-time-rule.time-rule-num NO-UNDO.
if p-mode = 'œ–Œ—ÃŒ“–':U then do:
    return error.
end.
if not available tt-dis-time-rule then do:
    create tt-dis-time-rule.
end.
assign frame Dialog-Frame
tt-dis-time-rule.des
.
IF vt-tree = "":U THEN DO:
    IF tt-dis-time-rule.date-from:SENSITIVE IN FRAME Dialog-Frame THEN
    ASSIGN
    tt-dis-time-rule.date-from
    .
    IF tt-dis-time-rule.date-to:SENSITIVE IN FRAME Dialog-Frame THEN
     ASSIGN
    tt-dis-time-rule.date-to
    .
    IF fhour:SENSITIVE IN FRAME Dialog-Frame THEN
     ASSIGN
    fhour
    fmin
    fsec
    tt-dis-time-rule.time-from = (fhour * 3600 + fmin * 60 + fsec)
     .
    IF thour:SENSITIVE IN FRAME Dialog-Frame THEN
     ASSIGN
    thour
    tmin
    tsec
    tt-dis-time-rule.time-to = (thour * 3600 + tmin * 60 + tsec)
     .
    IF tt-dis-time-rule.month-day:SENSITIVE IN FRAME Dialog-Frame THEN
     ASSIGN
    tt-dis-time-rule.month-day
     .
    IF tt-dis-time-rule.week-day-1:SENSITIVE IN FRAME Dialog-Frame THEN
    ASSIGN
    tt-dis-time-rule.week-day-1.
    IF tt-dis-time-rule.week-day-2:SENSITIVE IN FRAME Dialog-Frame THEN
    ASSIGN
    tt-dis-time-rule.week-day-2.
    IF tt-dis-time-rule.week-day-3:SENSITIVE IN FRAME Dialog-Frame THEN
    ASSIGN
    tt-dis-time-rule.week-day-3.
    IF tt-dis-time-rule.week-day-4:SENSITIVE IN FRAME Dialog-Frame THEN
    ASSIGN
    tt-dis-time-rule.week-day-4.
    IF tt-dis-time-rule.week-day-5:SENSITIVE IN FRAME Dialog-Frame THEN
    ASSIGN
    tt-dis-time-rule.week-day-5.
    IF tt-dis-time-rule.week-day-6:SENSITIVE IN FRAME Dialog-Frame THEN
    ASSIGN
    tt-dis-time-rule.week-day-6.
    IF tt-dis-time-rule.week-day-7:SENSITIVE IN FRAME Dialog-Frame THEN
    ASSIGN
    tt-dis-time-rule.week-day-7.
    IF RS-week-day:SENSITIVE IN FRAME Dialog-Frame THEN do:
      assign
      tt-dis-time-rule.week-day-0 = (if lookup("week-day-0", vt-level-1) > 0 then no else ?)
      tt-dis-time-rule.week-day-1 = (if lookup("week-day-1", vt-level-1) > 0 then no else ?)
      tt-dis-time-rule.week-day-2 = (if lookup("week-day-2", vt-level-1) > 0 then no else ?)
      tt-dis-time-rule.week-day-3 = (if lookup("week-day-3", vt-level-1) > 0 then no else ?)
      tt-dis-time-rule.week-day-4 = (if lookup("week-day-4", vt-level-1) > 0 then no else ?)
      tt-dis-time-rule.week-day-5 = (if lookup("week-day-5", vt-level-1) > 0 then no else ?)
      tt-dis-time-rule.week-day-6 = (if lookup("week-day-6", vt-level-1) > 0 then no else ?)
      tt-dis-time-rule.week-day-7 = (if lookup("week-day-7", vt-level-1) > 0 then no else ?)
      .
      ASSIGN
      rs-week-day
      tt-dis-time-rule.week-day-0 = (IF rs-week-day = 0
                                THEN yes
                                ELSE tt-dis-time-rule.week-day-0)
      tt-dis-time-rule.week-day-1 = (IF rs-week-day = 1
                            THEN yes
                            ELSE tt-dis-time-rule.week-day-1)
      tt-dis-time-rule.week-day-2 = (IF rs-week-day = 2
                            THEN yes
                            ELSE tt-dis-time-rule.week-day-2)
      tt-dis-time-rule.week-day-3 = (IF rs-week-day = 3
                            THEN yes
                            ELSE tt-dis-time-rule.week-day-3)
      tt-dis-time-rule.week-day-4 = (IF rs-week-day = 4
                            THEN yes
                            ELSE tt-dis-time-rule.week-day-4)
      tt-dis-time-rule.week-day-5 = (IF rs-week-day = 5
                            THEN  yes
                            ELSE tt-dis-time-rule.week-day-5)
      tt-dis-time-rule.week-day-6 = (IF rs-week-day = 6
                            THEN yes
                            ELSE tt-dis-time-rule.week-day-6)
      tt-dis-time-rule.week-day-7 = (IF rs-week-day = 7
                            THEN  yes
                            ELSE tt-dis-time-rule.week-day-7)
      .
    end.
END.
ELSE DO:
END.
run ref/diffdstr.p (
                input p-mode
              , INPUT TABLE tt-dis-time-rule
              , INPUT TABLE tt0-term_dis-time-rule
              , OUTPUT v-dub-time-rule-num) NO-ERROR.
IF ERROR-STATUS:ERROR
OR v-dub-time-rule-num <> 0 THEN DO:
  MESSAGE
  substitute("¬ ÒËÒÚÂÏÂ ÛÊÂ ÒÛ˘ÂÒÚ‚ÛÂÚ ÚÓ˜ÌÓ Ú‡ÍÓÂ ÊÂ ‡ÒÔËÒ‡ÌËÂ (‡ÒÔËÒ‡ÌËÂ π &1)", v-dub-time-rule-num) SKIP
  "¬˚ Û‚ÂÂÌ˚, ˜ÚÓ ıÓÚËÚÂ ÒÓÁ‰‡Ú¸ Â˘Â Ó‰ÌÓ Ú‡ÍÓÂ ÊÂ ‡ÒÔËÒ‡ÌËÂ?"
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE v-log.
  IF NOT v-log THEN undo, RETURN ERROR.
END.
run ref/dis-tim1.p (
 input (IF p-mode = 'ƒŒ¡¿¬À≈Õ»≈':U THEN ? ELSE tt-dis-time-rule.time-rule-num )
,input p-templ-rl-root
,input p-templ-rl-root
,input tt-dis-time-rule.des
,input tt-dis-time-rule.date-from
,input tt-dis-time-rule.date-to
,input tt-dis-time-rule.time-from
,input tt-dis-time-rule.time-to
,input tt-dis-time-rule.month-day
,input tt-dis-time-rule.week-day-0
,input tt-dis-time-rule.week-day-1
,input tt-dis-time-rule.week-day-2
,input tt-dis-time-rule.week-day-3
,input tt-dis-time-rule.week-day-4
,input tt-dis-time-rule.week-day-5
,input tt-dis-time-rule.week-day-6
,input tt-dis-time-rule.week-day-7
,input tt-dis-time-rule.upper-time-rule-num
,input tt-dis-time-rule.value-type
,input table tt0-term_dis-time-rule
,input-output p-recid
,input p-mode
,input NO
) NO-ERROR.
if error-status:error then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      undo ,
      return error.
    end.
    hh = hh:next-sibling.
  end.
end.
  undo, return error.
end.
END PROCEDURE.
PROCEDURE rename-term_dis-time-rule :
DEFINE variable v-time-from          like ub.dis-time-rule.time-from         no-undo .
DEFINE variable v-time-to            like ub.dis-time-rule.time-to           no-undo .
DEFINE variable v-date-from          like ub.dis-time-rule.date-from         no-undo .
DEFINE variable v-date-to            like ub.dis-time-rule.date-to           no-undo .
DEFINE variable v-week-day-0         like ub.dis-time-rule.week-day-0        no-undo .
DEFINE variable v-week-day-1         like ub.dis-time-rule.week-day-1        no-undo .
DEFINE variable v-week-day-2         like ub.dis-time-rule.week-day-2        no-undo .
DEFINE variable v-week-day-3         like ub.dis-time-rule.week-day-3        no-undo .
DEFINE variable v-week-day-4         like ub.dis-time-rule.week-day-4        no-undo .
DEFINE variable v-week-day-5         like ub.dis-time-rule.week-day-5        no-undo .
DEFINE variable v-week-day-6         like ub.dis-time-rule.week-day-6        no-undo .
DEFINE variable v-week-day-7         like ub.dis-time-rule.week-day-7        no-undo .
DEFINE variable v-month-day          like ub.dis-time-rule.month-day         no-undo .
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-time-rule-num LIKE ub.dis-time-rule.time-rule-num NO-UNDO.
DEFINE BUFFER buf_tt0-term_dis-time-rule FOR tt0-term_dis-time-rule.
IF vt-tree = "":U  THEN RETURN ERROR.
FOR EACH buf_tt0-term_dis-time-rule:
    buf_tt0-term_dis-time-rule.des = "".
END.
IF LOOKUP("date-from", vt-tree) > 0 THEN DO:
    FOR EACH buf_tt0-term_dis-time-rule
    BY buf_tt0-term_dis-time-rule.date-from DESCENDING:
        ASSIGN
        ii = ii + 1
        buf_tt0-term_dis-time-rule.des = buf_tt0-term_dis-time-rule.des + (IF buf_tt0-term_dis-time-rule.des = "":U THEN "@":U ELSE "":U) +
                                   substitute(" — &1 ", STRING(buf_tt0-term_dis-time-rule.date-from, "99/99/9999"))
        .
    END.
END.
IF LOOKUP("date-period", vt-tree) > 0 THEN DO:
    FOR EACH buf_tt0-term_dis-time-rule
    BY buf_tt0-term_dis-time-rule.date-from DESCENDING:
        ASSIGN
        ii = ii + 1
        buf_tt0-term_dis-time-rule.des = buf_tt0-term_dis-time-rule.des + (IF buf_tt0-term_dis-time-rule.des = "":U THEN "@":U ELSE "":U) +
                                   substitute(" — &1 ‰Ó &2"
                                                 , STRING(buf_tt0-term_dis-time-rule.date-from, "99/99/9999")
                                     , STRING(buf_tt0-term_dis-time-rule.date-to, "99/99/9999"))
        .
    END.
END.
IF LOOKUP("date-to", vt-tree) > 0 THEN DO:
    FOR EACH buf_tt0-term_dis-time-rule
    BY buf_tt0-term_dis-time-rule.date-to DESCENDING:
        ASSIGN
        ii = ii + 1
        buf_tt0-term_dis-time-rule.des = buf_tt0-term_dis-time-rule.des + (IF buf_tt0-term_dis-time-rule.des = "":U THEN "@":U ELSE "":U) +
                                   substitute(" œÓ &1 ", STRING(buf_tt0-term_dis-time-rule.date-to, "99/99/9999"))
.
    END.
END.
IF LOOKUP("time-from", vt-tree) > 0 THEN DO:
    FOR EACH buf_tt0-term_dis-time-rule
    BY buf_tt0-term_dis-time-rule.time-from DESCENDING:
        ASSIGN
        ii = ii + 1
        buf_tt0-term_dis-time-rule.des = buf_tt0-term_dis-time-rule.des + (IF buf_tt0-term_dis-time-rule.des = "":U THEN "@":U ELSE "":U) +
                                   substitute(" — &1 ", STRING(buf_tt0-term_dis-time-rule.time-from, "HH:MM:SS"))
.
    END.
END.
IF LOOKUP("time-to", vt-tree) > 0 THEN DO:
    FOR EACH buf_tt0-term_dis-time-rule
    BY buf_tt0-term_dis-time-rule.time-from DESCENDING:
        ASSIGN
        ii = ii + 1
        buf_tt0-term_dis-time-rule.des = buf_tt0-term_dis-time-rule.des + (IF buf_tt0-term_dis-time-rule.des = "":U THEN "@":U ELSE "":U) +
                                   substitute(" ƒÓ &1 ", STRING(buf_tt0-term_dis-time-rule.time-from, "HH:MM:SS"))
.
    END.
END.
IF LOOKUP("time-period", vt-tree) > 0 THEN DO:
    FOR EACH buf_tt0-term_dis-time-rule
    BY buf_tt0-term_dis-time-rule.time-from DESCENDING:
        ASSIGN
        ii = ii + 1
        buf_tt0-term_dis-time-rule.des = buf_tt0-term_dis-time-rule.des + (IF buf_tt0-term_dis-time-rule.des = "":U THEN "@":U ELSE "":U) +
                                   substitute(" — &1 ‰Ó &2 ", STRING(buf_tt0-term_dis-time-rule.time-from, "HH:MM:SS")
                                              , STRING(buf_tt0-term_dis-time-rule.time-to, "HH:MM:SS"))
.
    END.
END.
IF LOOKUP("month-day", vt-tree) > 0 THEN DO:
    FOR EACH buf_tt0-term_dis-time-rule
    BY buf_tt0-term_dis-time-rule.month-day DESCENDING:
        ASSIGN
        ii = ii + 1
        buf_tt0-term_dis-time-rule.des = buf_tt0-term_dis-time-rule.des + (IF buf_tt0-term_dis-time-rule.des = "":U THEN "@":U ELSE "":U) +
                                   substitute(" ◊ËÒÎÓ ÏÂÒˇˆ‡ &1 ", buf_tt0-term_dis-time-rule.month-day)
.
    END.
END.
IF LOOKUP("week-day-a", vt-tree) > 0
or LOOKUP("week-day-b", vt-tree) > 0 THEN DO:
    FOR EACH buf_tt0-term_dis-time-rule:
        ASSIGN
        buf_tt0-term_dis-time-rule.des = buf_tt0-term_dis-time-rule.des + (IF buf_tt0-term_dis-time-rule.des = "":U THEN "@":U ELSE "":U) +
                                   (IF buf_tt0-term_dis-time-rule.week-day-0 THEN " ¬ÒÂ ‰ÌË ÌÂ‰ÂÎË" ELSE "") +
                                   (IF buf_tt0-term_dis-time-rule.week-day-1 THEN " œÓÌÂ‰ÂÎ¸ÌËÍ" ELSE "") +
                                    (IF buf_tt0-term_dis-time-rule.week-day-2 THEN " ¬ÚÓÌËÍ" ELSE "") +
                                    (IF buf_tt0-term_dis-time-rule.week-day-3 THEN " —Â‰‡" ELSE "") +
                                    (IF buf_tt0-term_dis-time-rule.week-day-4 THEN " ◊ÂÚ‚Â„" ELSE "") +
                                    (IF buf_tt0-term_dis-time-rule.week-day-5 THEN " œˇÚÌËˆ‡" ELSE "") +
                                    (IF buf_tt0-term_dis-time-rule.week-day-6 THEN " —Û··ÓÚ‡" ELSE "") +
                                    (IF buf_tt0-term_dis-time-rule.week-day-7 THEN " ¬ÓÒÍÂÒÂÌ¸Â" ELSE "")
.
    END.
END.
IF LOOKUP("week-day-0", vt-tree) > 0  THEN DO:
    FOR EACH buf_tt0-term_dis-time-rule:
        ASSIGN
        buf_tt0-term_dis-time-rule.des = buf_tt0-term_dis-time-rule.des + (IF buf_tt0-term_dis-time-rule.des = "":U THEN "@":U ELSE "":U) +
                                   (IF buf_tt0-term_dis-time-rule.week-day-0 THEN " ¬ÒÂ ‰ÌË ÌÂ‰ÂÎË" ELSE "") +
                                   (IF buf_tt0-term_dis-time-rule.week-day-1 THEN " œÌ" ELSE "") +
                                    (IF buf_tt0-term_dis-time-rule.week-day-2 THEN " ¬Ú" ELSE "") +
                                    (IF buf_tt0-term_dis-time-rule.week-day-3 THEN " —" ELSE "") +
                                    (IF buf_tt0-term_dis-time-rule.week-day-4 THEN " ◊Ú" ELSE "") +
                                    (IF buf_tt0-term_dis-time-rule.week-day-5 THEN " œÚÌ" ELSE "") +
                                    (IF buf_tt0-term_dis-time-rule.week-day-6 THEN " —·" ELSE "") +
                                    (IF buf_tt0-term_dis-time-rule.week-day-7 THEN " ¬Ò" ELSE "")
.
    END.
END.
END PROCEDURE.
