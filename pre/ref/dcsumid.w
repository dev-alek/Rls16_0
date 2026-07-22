DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-parent-handle AS HANDLE NO-UNDO.
define input parameter p-mode as character no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-sum-id-type AS CHARACTER NO-UNDO.
define INPUT-OUTPUT parameter p-dt-code   AS integer no-undo .
define INPUT-OUTPUT parameter p-host-code like ub.sysconf.host-code no-undo .
define INPUT-OUTPUT parameter p-obj-type like ub.clients.obj-type no-undo .
define INPUT-OUTPUT parameter p-obj-code like ub.clients.obj-code no-undo .
define INPUT-OUTPUT parameter p-r-b AS character no-undo .
define INPUT-OUTPUT parameter p-field AS character no-undo .
define INPUT-OUTPUT parameter p-cond as character no-undo .
define INPUT-OUTPUT parameter p-last-change-date as date no-undo .
define output parameter p-field-des as character no-undo .
define OUTPUT parameter p-low as decimal no-undo .
define OUTPUT parameter p-high as decimal no-undo .
DEFINE OUTPUT PARAMETER p-ok AS logical NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Задание значений по суммам итогов по ДК".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable dcard-algo-field-name as character no-undo extent 3 init [
 'd-pcnt':U
,'cash-d-pcnt':U
,'pcnt-kat':U].
define variable algo-field-abbr as character no-undo extent 3 init [
 'ITEM%':U
,'TOTAL%':U
,'CATEG':U].
FUNCTION dct-algo-Date-to-String returns character(input  p-date as date):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + chr(47) +
             string(Month(p-date), "99":U) + chr(47) +
             string(DAY(p-date), "99":U).
return v-date-str.
END FUNCTION.
function dct-algo-string-to-date returns date ( input p-string  as character):
  define variable v-date as date no-undo .
  assign
  v-date = date(integer(substring(p-string, 6, 2))
                ,integer(substring(p-string, 9, 2))
                ,integer(substring(p-string, 1, 4))
               ) no-error .
  if error-status:error then return ?.
  return v-date.
END FUNCTION.
FUNCTION dct-algo-get-sum-id-from-DT-CODE returns character ( input p-DT-CODE as integer):
define buffer buf_prop-ref for ub.prop-ref.
find first buf_prop-ref no-lock where
          buf_prop-ref.DT-CODE = p-DT-CODE no-error.
if not available buf_prop-ref then do:
  return chr(63).
end.
return buf_prop-ref.sum-id.
END FUNCTION.
FUNCTION dct-algo-get-description-sum-id returns character ( input p-dt-code as integer):
define variable v-des as character no-undo .
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-head for ub.prop-head.
find first buf_prop-ref no-lock where
          buf_prop-ref.dt-code = p-dt-code no-error.
if not available buf_prop-ref then do:
  return substitute("Срез/итог по ДК c кодом &1 - срез не найден", p-dt-code).
end.
find first buf_prop-head no-lock where
        buf_prop-head.dtm-code = buf_prop-ref.dtm-code no-error.
if not available buf_prop-head then do:
  return substitute("Срез/итог по ДК &1 c кодом &2 - неизвестное", p-dt-code, buf_prop-ref.dtm-code).
end.
assign
v-des = substitute("&1  &2 &3"
                  , buf_prop-head.prop-name
                  , buf_prop-ref.sum-id
                  , buf_prop-ref.caller_id).
return v-des.
end FUNCTION.
FUNCTION dct-algo-get-description-node-code returns character ( input p-dtm-code as integer
                                                            ,input p-dt-code as integer
                                                            ,input p-node-code as integer
                                                            ):
define variable v-des as character no-undo .
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-map for ub.prop-map.
find first buf_prop-ref no-lock where
          buf_prop-ref.dt-code = p-dt-code no-error.
if not available buf_prop-ref then do:
  return substitute("Срез/итог по ДК c кодом &1 - срез не найден", p-dt-code).
end.
find first buf_prop-head no-lock where
        buf_prop-head.dtm-code = p-dtm-code no-error.
if not available buf_prop-head then do:
  return substitute("Срез/итог по ДК &1 c кодом &2 - неизвестное", p-dt-code, p-dtm-code).
end.
find first buf_prop-map no-lock where
        buf_prop-map.dtm-code = p-dtm-code
    and buf_prop-map.node-code = p-node-code no-error .
if not available buf_prop-map then do:
  return substitute("Срез/итог по ДК &1, &2.&3 - неизвестно"
                    , p-dt-code
                    , buf_prop-head.prop-label
                    , p-node-code).
end.
assign
v-des = substitute("&1.&2 &3 &4"
                  , buf_prop-head.prop-label
                  , buf_prop-map.node-label
                  , buf_prop-ref.sum-id
                  , buf_prop-ref.caller_id).
return v-des.
end FUNCTION.
function dct-algo-get-prev-sum-id RETURNS integer (
                                                    input p-dt-code as integer
                                                   ):
define variable v-dtm-code as integer no-undo .
define variable v-sum-id as character no-undo .
define variable v-caller-id as character no-undo .
define buffer buf_prop-ref for ub.prop-ref.
find first buf_prop-ref no-lock where
        buf_prop-ref.dt-code = p-dt-code no-error.
if not available buf_prop-ref then return ?.
assign
v-dtm-code = buf_prop-ref.dtm-code
v-sum-id = buf_prop-ref.sum-id.
v-caller-id = buf_prop-ref.caller_id.
find last buf_prop-ref no-lock where
          buf_prop-ref.dtm-code = v-dtm-code
     and  buf_prop-ref.sum-id < v-sum-id
     and  buf_prop-ref.caller_id = v-caller-id
     no-error.
if available buf_prop-ref then return buf_prop-ref.dt-code.
return -1 .
END FUNCTION.
FUNCTION dct-algo-get_dcproperty-value returns logical (
                                                          input p-prop-name as character
                                                        , input p-d-card    as character
                                                        , input p-host-code as integer
                                                        , input p-obj-type  as character
                                                        , input p-obj-code  as integer
                                                        , output p-value-character as character
                                                        , output p-value-date   as date
                                                        , output p-value-integer as integer
                                                        , output p-value-decimal as decimal
                                                        , output p-value-logical as logical):
  return no.
END FUNCTION.
FUNCTION dct-algo-get_dcproperty-value-chr returns logical (
                                                          input p-d-card    as character
                                                        , input p-emitent-host-code as integer
                                                        , input p-type as character
                                                        , input p-host-code as integer
                                                        , input p-obj-type  as character
                                                        , input p-obj-code  as integer
                                                        , output p-value-chr as character):
define variable v-dt-code as integer no-undo .
define variable v-node-code as integer no-undo .
define variable v-field-name as character no-undo .
define variable v-storage-place as character no-undo .
define variable v-sum-id-value as character no-undo .
define variable v-sum-id-output as logical no-undo .
define variable v-value-chr as character no-undo .
define variable v-ii as integer no-undo .
define buffer buf_dis-card-property for ub.dis-card-property.
define buffer buf_dis-host for ub.dis-host.
define buffer buf_dis-obj for ub.dis-obj.
run get-cd-sumid in this-procedure (
                                      input p-emitent-host-code
                                     ,input p-type
                                     ,input p-host-code
                                     ,input p-obj-type
                                     ,input p-obj-code
                                     ,output v-sum-id-value
                                     ,output v-sum-id-output
                                    ) no-error.
if not v-sum-id-output then do:
  return no.
end.
do v-ii = 1 to num-entries(v-sum-id-value):
  assign
  v-storage-place = entry(1, entry(v-ii, v-sum-id-value), chr(4))
  v-dt-code = integer(entry(2, entry(v-ii, v-sum-id-value), chr(4)))
  v-node-code = integer(entry(3, entry(v-ii, v-sum-id-value), chr(4)))
  v-field-name = entry(4, entry(v-ii, v-sum-id-value), chr(4))
  no-error .
  if not error-status:error then do:
    case v-storage-place:
      when 'dis-card-property':U then do:
        find first buf_dis-card-property no-lock where
                  buf_dis-card-property.d-card = p-d-card
            and  buf_dis-card-property.host-code = p-host-code
            and  buf_dis-card-property.obj-type = p-obj-type
            and  buf_dis-card-property.obj-code = p-obj-code
            and  buf_dis-card-property.dt-code = v-dt-code
            and  buf_dis-card-property.node-code = v-node-code no-error .
        if available buf_dis-card-property then do:
          v-value-chr = buffer buf_dis-card-property:handle:buffer-field(v-field-name):string-value.
        end.
        else do:
          v-value-chr = chr(63).
        end.
      end.
      when 'dis-obj':U then do:
        find first buf_dis-obj no-lock where
                  buf_dis-obj.d-card = p-d-card
            and  buf_dis-obj.obj-type = p-obj-type
            and  buf_dis-obj.obj-code = p-obj-code
            and  buf_dis-obj.dt-code = v-dt-code no-error .
        if available buf_dis-obj then do:
          v-value-chr = buffer buf_dis-obj:handle:buffer-field(v-field-name):string-value.
        end.
        else do:
          v-value-chr = chr(63).
        end.
      end.
      when 'dis-host':U then do:
        find first buf_dis-host no-lock where
                  buf_dis-host.d-card = p-d-card
            and  buf_dis-host.host-code = p-host-code
            and  buf_dis-host.dt-code = v-dt-code no-error .
        if available buf_dis-host then do:
          v-value-chr = buffer buf_dis-host:handle:buffer-field(v-field-name):string-value.
        end.
        else do:
          v-value-chr = chr(63).
        end.
      end.
    end.
  end.
  p-value-chr = p-value-chr + (if v-ii = 1 then '':U else chr(44)) + v-value-chr.
end.
END FUNCTION.
FUNCTION dct-algo_custom-sent-description RETURNS CHARACTER
  ( INPUT p-custom-sent as character ) :
DEFINE VARIABLE v-storage-place AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dtm-code AS integer NO-UNDO.
DEFINE VARIABLE v-sum-id AS character NO-UNDO.
DEFINE VARIABLE v-caller-id AS character NO-UNDO.
DEFINE VARIABLE v-node-code AS INTEGER NO-UNDO.
DEFINE VARIABLE v-sum-id-description AS CHARACTER.
DEFINE BUFFER buf_prop-ref FOR ub.prop-ref.
IF p-custom-sent = chr(63) THEN RETURN "Не отсылать".
assign
v-storage-place = entry(1, p-custom-sent, chr(4))
v-dtm-code = integer(entry(2, p-custom-sent, chr(4)))
v-sum-id   = entry(3, p-custom-sent, chr(4))
v-caller-id = entry(4, p-custom-sent, chr(4))
v-node-code = integer(entry(5, p-custom-sent, chr(4)))
no-error .
IF ERROR-STATUS:ERROR THEN DO:
  MESSAGE
  "Не могу разобрать строку, описывающую итог"
   VIEW-AS ALERT-BOX WARNING.
  RETURN chr(63).
END.
FIND FIRST buf_prop-ref NO-LOCK WHERE
          buf_prop-ref.dtm-code = v-dtm-code
     AND  buf_prop-ref.sum-id = v-sum-id
     AND  buf_prop-ref.caller_id = v-caller-id NO-ERROR.
IF NOT AVAILABLE buf_prop-ref THEN DO:
  FIND FIRST buf_prop-ref NO-LOCK WHERE
            buf_prop-ref.dtm-code = v-dtm-code
      AND  buf_prop-ref.caller_id = v-caller-id NO-ERROR.
  IF NOT AVAILABLE buf_prop-ref THEN DO:
      MESSAGE
      "Не могу разобрать строку, описывающую итог"
       VIEW-AS ALERT-BOX WARNING.
      RETURN chr(63).
   end.
end.
ASSIGN
v-sum-id-description =  dct-algo-get-description-node-code ( v-dtm-code
                                                       ,buf_prop-ref.dt-code
                                                       ,v-node-code).
RETURN v-sum-id-description.
END FUNCTION.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
define variable is-temp as logical no-undo .
define variable v-obj-db-num like ub.db.db-num no-undo .
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-host
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-sum-id
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE VARIABLE CB-obj-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEMS "","Item 1","Item 2"
     DROP-DOWN-LIST
     SIZE 11 BY 1
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE f-high AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Верхняя граница"
     VIEW-AS FILL-IN
     SIZE 27.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-host-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Фирма"
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE F-host-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 56.5 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE f-last-change-date AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "Дата последнего изменения"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE f-low AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Нижняя граница"
     VIEW-AS FILL-IN
     SIZE 27.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-obj-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE F-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 56.5 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE f-sum-id AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 46 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE rs-cond AS CHARACTER INITIAL ">"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "=", "=",
">", ">",
"<", "<",
">=", ">=",
"<=", "<="
     SIZE 30.5 BY 1 NO-UNDO.
DEFINE VARIABLE rs-field AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Количество чеков", "num-chk",
"Сумма оплат", "pay-tot-rubl",
"Сумма покупок брутто", "gds-tot-rubl",
"Сумма скидок", "gds-dis-rubl"
     SIZE 26 BY 6.5 NO-UNDO.
DEFINE VARIABLE rs-r-b AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Нац. валюта", "rubl",
"Баз.вал.", "base"
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE RS-range AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Глобально", "global",
"Фирма", "firm",
"Объект", "object"
     SIZE 36 BY 1 NO-UNDO.
DEFINE VARIABLE Rs-sum-id-type AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Общие итоги", "general-sum-id",
"Частные итоги", "partial-sum-id"
     SIZE 31 BY 1 NO-UNDO.
DEFINE FRAME DIALOG-FRAME
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.9
     Rs-sum-id-type AT ROW 2.5 COL 2 NO-LABEL
     B-sum-id AT ROW 2.5 COL 33
     RS-range AT ROW 4 COL 2 NO-LABEL
     f-host-code AT ROW 5.5 COL 13 COLON-ALIGNED
     B-host AT ROW 5.5 COL 23
     CB-obj-type AT ROW 7 COL 2.5 NO-LABEL
     f-obj-code AT ROW 7 COL 13 COLON-ALIGNED NO-LABEL
     B-obj AT ROW 7 COL 23
     rs-r-b AT ROW 8.5 COL 2 NO-LABEL
     f-low AT ROW 9 COL 49 COLON-ALIGNED
     rs-field AT ROW 10 COL 3 NO-LABEL
     f-high AT ROW 11 COL 49 COLON-ALIGNED
     f-last-change-date AT ROW 12.73 COL 61.5 COLON-ALIGNED
     rs-cond AT ROW 14.6 COL 50.5 NO-LABEL
     f-sum-id AT ROW 2.5 COL 36 COLON-ALIGNED NO-LABEL
     F-host-name AT ROW 5.77 COL 24 COLON-ALIGNED NO-LABEL
     F-obj-name AT ROW 7.27 COL 24 COLON-ALIGNED NO-LABEL
     SPACE(2.37) SKIP(9.01)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Задание диапазона значений общих или частных итогов по ДК"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME DIALOG-FRAME:SCROLLABLE       = FALSE
       FRAME DIALOG-FRAME:HIDDEN           = TRUE.
ASSIGN
       f-host-code:READ-ONLY IN FRAME DIALOG-FRAME        = TRUE.
ASSIGN
       f-obj-code:READ-ONLY IN FRAME DIALOG-FRAME        = TRUE.
ON WINDOW-CLOSE OF FRAME DIALOG-FRAME
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME DIALOG-FRAME
DO:
  run proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  ASSIGN
  p-ok = YES
  p-host-code = (if p-host-code <> f-host-code then f-host-code else p-host-code)
  p-obj-type = (if p-obj-type <> cb-obj-type then cb-obj-type else p-obj-type)
  p-obj-code = (if p-obj-code <> f-obj-code then f-obj-code else p-obj-code)
  p-sum-id-type = (if p-sum-id-type <> rs-sum-id-type then rs-sum-id-type else p-sum-id-type)
  p-dt-code = (if p-dt-code <> integer(f-sum-id:private-data) then integer(f-sum-id) else p-dt-code)
  .
  CASE p-mode:
    WHEN 'last-change' THEN DO:
        ASSIGN
        p-cond = rs-cond
        p-last-change-date = f-last-change-date
        p-field-des = substitute("Дата последнего изменения")
        .
    END.
    WHEN 'current-values' THEN DO:
        ASSIGN
        p-field = (if p-field <> rs-field then rs-field else p-field)
        p-r-b = (if p-r-b <> rs-r-b then rs-r-b else p-r-b)
        p-low = f-low
        p-high = f-high
        p-field-des = substitute("&1 &2"
                                ,  radio-label (
                                    input p-field
                                   ,input rs-field:radio-buttons in frame DIALOG-FRAME )
                               ,  (if p-field = 'num-chk'
                                    then '':U
                                    else radio-label (
                                                      input p-r-b
                                                      ,input rs-r-b:radio-buttons in frame DIALOG-FRAME ) ))
        .
    END.
  END CASE.
END.
ON CHOOSE OF B-host IN FRAME DIALOG-FRAME
DO:
  run proc-b-host IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-obj IN FRAME DIALOG-FRAME
DO:
  run proc-b-obj IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-sum-id IN FRAME DIALOG-FRAME
DO:
DEFINE variable v-ref-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-ref FOR ub.prop-ref.
run ref/proprefs.w (
                input parparentproc
              ,input 'b-sel'
              ,input 'dis-tot':U
              ,input 0
              ,input '':U
              ,input '':U
              ,input-output  v-ref-list) no-error.
if error-status:error or v-ref-list = '':u then do:
  return.
end.
find first buf_prop-ref no-lock where
          recid(buf_prop-ref) = integer(v-ref-list) no-error.
if not available buf_prop-ref then return.
ASSIGN
f-sum-id:PRIVATE-DATA = string(buf_prop-ref.dt-code)
f-sum-id = buf_prop-ref.sum-id.
DISPLAY
f-sum-id
WITH FRAME DIALOG-FRAME.
END.
ON VALUE-CHANGED OF rs-field IN FRAME DIALOG-FRAME
DO:
  IF rs-field = 'num-chk'
  OR INPUT FRAME DIALOG-FRAME rs-field = 'num-chk' THEN DO:
      ASSIGN
      f-low =0.0
      f-high = 0.0
      .
      HIDE
      f-low
      f-high
      IN FRAME DIALOG-FRAME.
  END.
  ASSIGN
  rs-field.
  CASE rs-field:
      WHEN "num-chk" THEN DO:
          ASSIGN
          f-low:FORMAT IN FRAME DIALOG-FRAME = '->>>>>>>>9'
          f-high:FORMAT IN FRAME DIALOG-FRAME = '->>>>>>>>9'
          .
      END.
      OTHERWISE DO:
          ASSIGN
          f-low:FORMAT IN FRAME DIALOG-FRAME = '->>>,>>>,>>>,>>9.99'
          f-high:FORMAT IN FRAME DIALOG-FRAME = '->>>,>>>,>>>,>>9.99'
          .
      END.
  END CASE.
  display
  f-low
  f-high
  with frame DIALOG-FRAME .
END.
ON VALUE-CHANGED OF RS-range IN FRAME DIALOG-FRAME
DO:
  ASSIGN
  rs-range.
  CASE rs-range:
      WHEN "GLOBAL":U THEN DO:
         ASSIGN
         f-host-code = 0
         f-host-name = '':U
         cb-obj-type = '':U
         f-obj-code = 0
         f-obj-name = '':U.
         DISABLE
         b-host
         b-obj
         WITH FRAME DIALOG-FRAME.
         DISPLAY
         f-host-code
         f-host-name
         cb-obj-type
         f-obj-code
         f-obj-name
         WITH FRAME DIALOG-FRAME.
      END.
      WHEN "firm":U THEN DO:
          ASSIGN
          cb-obj-type = '':U
          f-obj-code = 0
          f-obj-name = '':U.
          DISABLE
          b-obj
          WITH FRAME DIALOG-FRAME.
          DISPLAY
          f-host-code
          f-host-name
          cb-obj-type
          f-obj-code
          f-obj-name
          WITH FRAME DIALOG-FRAME.
          ENABLE
          b-host
          WITH FRAME DIALOG-FRAME.
      END.
      WHEN "object":U THEN DO:
          ASSIGN
          f-host-code = 0
          f-host-name = '':U
          cb-obj-type = '':U
          f-obj-code = 0
          f-obj-name = '':U.
          DISABLE
          b-host
          WITH FRAME DIALOG-FRAME.
          DISPLAY
          f-host-code
          f-host-name
          cb-obj-type
          f-obj-code
          f-obj-name
          WITH FRAME DIALOG-FRAME.
          ENABLE
          b-obj
          WITH FRAME DIALOG-FRAME.
      END.
  END CASE.
END.
ON VALUE-CHANGED OF Rs-sum-id-type IN FRAME DIALOG-FRAME
DO:
ASSIGN
rs-sum-id-type.
CASE rs-sum-id-type:
  WHEN 'general-sum-id':U THEN DO:
    f-sum-id = '':U.
    DISABLE
    b-sum-id
    WITH FRAME DIALOG-FRAME.
    DISPLAY f-sum-id
    WITH FRAME DIALOG-FRAME.
  END.
  WHEN 'partial-sum-id':U THEN DO:
    ENABLE
    b-sum-id
    WITH FRAME DIALOG-FRAME.
  END.
END CASE.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME DIALOG-FRAME:PARENT eq ?
THEN FRAME DIALOG-FRAME:PARENT = ACTIVE-WINDOW.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame DIALOG-FRAME
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
on choose of b-help in frame DIALOG-FRAME
do:
  apply "help":u to frame DIALOG-FRAME .
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
                v-frame-width = frame DIALOG-FRAME:width - 0.3
                fh            = frame DIALOG-FRAME:first-child
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  fh = frame DIALOG-FRAME:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
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
  fh = frame DIALOG-FRAME:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    fh = frame DIALOG-FRAME:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
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
    fh = frame DIALOG-FRAME:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run Myenable in this-procedure .
  WAIT-FOR GO OF FRAME DIALOG-FRAME.
END.
run disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME DIALOG-FRAME.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY Rs-sum-id-type RS-range f-host-code CB-obj-type f-obj-code rs-r-b
          f-low rs-field f-high f-last-change-date rs-cond f-sum-id F-host-name
          F-obj-name
      WITH FRAME DIALOG-FRAME.
  ENABLE B-exit b-quit B-Help Rs-sum-id-type B-sum-id RS-range B-host
         CB-obj-type B-obj rs-r-b f-low rs-field f-high f-last-change-date
         rs-cond f-sum-id F-host-name F-obj-name
      WITH FRAME DIALOG-FRAME.
  VIEW FRAME DIALOG-FRAME.
END PROCEDURE.
PROCEDURE MyEnable :
define buffer buf_clients for ub.clients.
ASSIGN
v-tab-order = "b-exit,b-quit,b-help,rs-sum-id,b-sum-id,rs-range,b-host,b-obj,rs-r-b,rs-field,f-low,f-high," +
              "f-last-change-date,rs-cond"
.
ASSIGN
rs-r-b:RADIO-BUTTONS IN FRAME DIALOG-FRAME = "руб" + chr(44) + 'rubl':U + chr(44) +
                                              "Баз.вал." + chr(44) + 'base':U
CB-obj-type:list-items = '':U + chr(44) + 'маг':U + chr(44) + 'скл':U
.
ASSIGN
rs-sum-id-type = (IF p-sum-id-type = '':U THEN 'general-sum-id' ELSE p-sum-id-type).
IF p-host-code <> 0  THEN DO:
FIND FIRST buf_clients NO-LOCK WHERE
         buf_clients.obj-code = p-host-code
      AND buf_clients.obj-type = 'орг':U NO-ERROR.
if available buf_clients then do:
    assign
    f-host-CODE = p-host-code
    f-host-name = buf_clients.obj-name
    .
    DISPLAY
    f-host-code
    f-host-name
    WITH FRAME DIALOG-FRAME.
END.
END.
IF NOT ( p-obj-type = '':U
         AND p-obj-code = 0) THEN DO:
    FIND FIRST buf_clients NO-LOCK WHERE
           buf_clients.obj-type = p-obj-type
       AND  buf_clients.obj-code = p-obj-code NO-ERROR.
    if available buf_clients then do:
        assign
        f-obj-CODE = buf_clients.obj-code
        CB-obj-type = buf_clients.obj-type
        f-obj-name = buf_clients.obj-name
        .
        DISPLAY
        f-obj-code
        cb-obj-type
        f-obj-name
        WITH FRAME DIALOG-FRAME.
    END.
END.
ASSIGN
CB-obj-type = p-obj-type
f-obj-code = p-obj-code
.
ASSIGN
rs-field = (IF p-field = '':U THEN 'pay-tot-rubl' ELSE p-field).
ASSIGN
rs-r-b = (IF p-r-b = '':U THEN 'rubl':U ELSE p-r-b)
.
if rs-sum-id-type = 'partial-sum-id' then do:
  define variable v-sum-id as character no-undo .
   v-sum-id = dct-algo-get-sum-id-from-dt-code (input p-dt-code).
   if p-dt-code <> 0
  AND CAN-FIND (FIRST ub.prop-ref WHERE
                    ub.prop-ref.sum-id = v-sum-id)
  THEN
  ASSIGN
  f-sum-id:PRIVATE-DATA = string(p-dt-code)
  f-sum-id = dct-algo-get-description-sum-id(input p-dt-code)
  .
end.
IF f-obj-code > 0 THEN DO:
    ASSIGN
    rs-range = "object":U.
END.
ELSE do:
   IF f-host-code > 0 THEN DO:
     ASSIGN
     rs-range = "firm":U.
   END.
   ASSIGN
   rs-range ="global":U.
END.
ASSIGN
f-last-change-date = p-last-change-date
rs-cond = p-cond.
DISPLAY
rs-range
rs-sum-id-type
f-sum-id
f-host-code
CB-obj-type
f-obj-code
rs-r-b
rs-field
rs-cond
f-last-change-date
WITH FRAME DIALOG-FRAME
.
ENABLE
B-exit
b-quit
B-Help
b-host
b-obj
b-sum-id when p-sum-id-type <> 'general-sum-id':U
rs-r-b
f-low
f-high
rs-field
rs-sum-id-type when p-sum-id-type = '':U
rs-range
rs-cond
f-last-change-date
WITH FRAME DIALOG-FRAME.
VIEW FRAME DIALOG-FRAME.
APPLY "VALUE-CHANGED" to rs-range.
APPLY "VALUE-CHANGED" to rs-field.
if RS-sum-id-type:SENSITIVE In FRAME DIALOG-FRAME THEN DO:
  APPLY "VALUE-CHANGED" to rs-sum-id-type.
end.
RUN process-mode-interface IN THIS-PROCEDURE ( INPUT p-mode).
END PROCEDURE.
PROCEDURE proc-b-host :
define VARIABLE v-host-code LIKE ub.sysconf.host-code no-undo .
define variable v-rid-list as character no-undo .
define buffer buf_clients  for ub.clients.
  do
  on error undo, return error
  :
        run adm/sconfs.w (
              input parParentProc
            , input "b-sel":U
            , input no
            , input v-cntxt-host-code-obj
            , output v-host-code
            , input-output v-rid-list
        ) no-error.
      IF v-rid-list = '':U THEN RETURN NO-APPLY.
      FIND FIRST buf_clients NO-LOCK WHERE
                 buf_clients.obj-code = v-host-code
              AND buf_clients.obj-type = 'орг':U NO-ERROR.
      if not available buf_clients then do:
           return error.
      end.
      assign
      f-host-CODE = v-host-code
      f-host-name = buf_clients.obj-name
      .
      DISPLAY
      f-host-code
      f-host-name
      WITH FRAME DIALOG-FRAME.
  end.
END PROCEDURE.
PROCEDURE proc-b-obj :
define variable v-rid-list as character no-undo .
define buffer buf_clients  for ub.clients.
define buffer buf_clients-host  for ub.clients.
  do
  on error undo, return error
  :
       run ref/cli-all.w (
                 INPUT parparentproc
                ,INPUT "b-sel"
                ,INPUT 'объект':U
                ,INPUT 'все':U
                ,INPUT 'текущие':U
                ,INPUT ?
                ,INPUT ",,,,,,NO,,"
                ,INPUT "lock-cli-type"
                ,output v-rid-list ) NO-ERROR.
     IF v-rid-list = '':U THEN RETURN error.
      FIND FIRST buf_clients NO-LOCK WHERE
          RECID( buf_clients) = INTEGER( v-rid-list ) NO-ERROR.
      if not available buf_clients then do:
           return error.
      end.
      IF NOT (buf_clients.obj-type = 'маг':U
              OR
              buf_clients.obj-type = 'скл':U)
              THEN DO:
          MESSAGE
          substitute("Неверный тип объекта &1", buf_clients.obj-type)
          VIEW-AS ALERT-BOX ERROR.
          RETURN ERROR.
      END.
      FIND FIRST buf_clients-host NO-LOCK WHERE
                buf_clients-host.obj-type = 'орг':U
          AND   buf_clients-host.obj-code = buf_clients.host-code NO-ERROR.
         IF NOT AVAILABLE buf_clients-host THEN DO:
             MESSAGE
             SUBSTITUTE("Не найдена фирма &1 для объекта &2&3"
                        , buf_clients.host-code
                        , buf_clients.obj-type
                        , buf_clients.obj-code)
              VIEW-AS ALERT-BOX ERROR.
             RETURN ERROR.
         END.
      assign
      f-obj-CODE = buf_clients.obj-code
      CB-obj-type = buf_clients.obj-type
      f-obj-name = buf_clients.obj-name
      f-host-code = buf_clients.host-code
      f-host-name = buf_clients-host.obj-name
      .
      DISPLAY
      f-obj-code
      cb-obj-type
      f-obj-name
      f-host-name
      f-host-code
      WITH FRAME DIALOG-FRAME.
  end.
END PROCEDURE.
PROCEDURE proc-save :
DEFINE BUFFER buf_clients for ub.clients.
DEFINE BUFFER buf_sysconf     FOR ub.sysconf.
DEFINE BUFFER buf_prop-ref    FOR ub.prop-ref.
ASSIGN FRAME DIALOG-FRAME
f-host-code when f-host-code:sensitive in frame DIALOG-FRAME
CB-obj-type when cb-obj-type:sensitive in frame DIALOG-FRAME
f-obj-code   when f-obj-code:sensitive in frame DIALOG-FRAME
rs-sum-id-type when rs-sum-id-type:sensitive in frame DIALOG-FRAME
f-sum-id   when f-sum-id:sensitive in frame DIALOG-FRAME
rs-field   when (rs-field:sensitive in frame DIALOG-FRAME AND rs-field:visible in frame DIALOG-FRAME)
rs-r-b  when (rs-r-b:sensitive in frame DIALOG-FRAME AND rs-r-b:visible in frame DIALOG-FRAME)
f-low WHEN f-low:VISIBLE IN FRAME DIALOG-FRAME
f-high WHEN f-high:VISIBLE IN FRAME DIALOG-FRAME
f-last-change-date WHEN (f-last-change-date:SENSITIVE IN FRAME DIALOG-FRAME AND f-last-change-date:visible IN FRAME DIALOG-FRAME)
rs-cond WHEN (rs-cond:SENSITIVE IN FRAME DIALOG-FRAME AND rs-cond:visible IN FRAME DIALOG-FRAME)
.
IF f-host-code <> 0  THEN DO:
find FIRST buf_sysconf NO-LOCK WHERE
         buf_sysconf.host-code = f-host-code  NO-ERROR.
    IF NOT AVAILABLE buf_sysconf THEN DO:
        MESSAGE
        "Неверный номер фирмы"
        VIEW-AS ALERT-BOX.
        UNDO, RETURN ERROR.
    END.
END.
IF NOT (cb-obj-type = '':U AND f-obj-code = 0) THEN DO:
  find FIRST buf_clients NO-LOCK WHERE
            buf_clients.obj-type = cb-obj-type
       AND buf_clients.obj-code = f-obj-code NO-ERROR.
    IF NOT AVAILABLE buf_clients THEN DO:
        MESSAGE
        "Неверный номер объекта"
        VIEW-AS ALERT-BOX.
        UNDO, RETURN ERROR.
    END.
    IF NOT (buf_clients.obj-type = 'маг':U
            OR
            buf_clients.obj-type = 'скл':U)
            THEN DO:
    message
    "Неверный тип объекта"
    VIEW-AS ALERT-BOX.
    UNDO, RETURN ERROR.
  END.
END.
IF rs-sum-id-type = 'partial-sum-id':U THEN do:
    FIND FIRST buf_prop-ref NO-LOCK WHERE
             buf_prop-ref.sum-id = f-sum-id NO-ERROR.
   IF NOT AVAILABLE buf_prop-ref THEN DO:
       MESSAGE
       substitute("Неверный частный итог &1", f-sum-id)
       VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
   END.
END.
END PROCEDURE.
PROCEDURE process-mode-interface :
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
CASE p-mode:
  WHEN "last-change" THEN DO:
    HIDE
    f-high IN FRAME DIALOG-FRAME
    f-low
    rs-field
    rs-r-b
    IN FRAME DIALOG-FRAME.
  END.
  WHEN "current-values" THEN DO:
    HIDE
    f-last-change-date IN FRAME DIALOG-FRAME
    rs-cond
    IN FRAME DIALOG-FRAME.
  END.
END CASE.
END PROCEDURE.
