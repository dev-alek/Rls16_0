define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code as integer no-undo .
define input parameter p-curr-obj-type as character no-undo .
define input parameter p-curr-obj-code as integer no-undo .
define input-output parameter p-dtm-code as integer no-undo .
define input-output parameter p-dt-code as integer no-undo .
define input-output parameter p-node-code as integer no-undo .
define INPUT-OUTPUT parameter p-host-code like ub.sysconf.host-code no-undo .
define INPUT-OUTPUT parameter p-obj-type like ub.clients.obj-type no-undo .
define INPUT-OUTPUT parameter p-obj-code like ub.clients.obj-code no-undo .
define INPUT-OUTPUT parameter p-cond as character no-undo .
DEFINE output PARAMETER p-value-character-low AS CHARACTER NO-UNDO.
DEFINE output PARAMETER p-value-character-high AS CHARACTER NO-UNDO.
DEFINE output PARAMETER p-value-date-low AS date NO-UNDO.
DEFINE output PARAMETER p-value-date-high AS date NO-UNDO.
DEFINE output PARAMETER p-value-decimal-low AS decimal NO-UNDO.
DEFINE output PARAMETER p-value-decimal-high AS decimal NO-UNDO.
DEFINE output PARAMETER p-value-integer-low AS integer NO-UNDO.
DEFINE output PARAMETER p-value-integer-high AS integer NO-UNDO.
DEFINE output PARAMETER p-value-logical-low AS logical NO-UNDO.
DEFINE output PARAMETER p-value-logical-high AS logical NO-UNDO.
DEFINE OUTPUT PARAMETER p-ok AS logical NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор объекта, среза, свойства ДК".
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
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
DEFINE VARIABLE link-option AS CHARACTER NO-UNDO.
define variable v-short-mode as logical no-undo .
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
DEFINE BUFFER buf_prop-ref FOR ub.prop-ref.
define buffer buf_prop-map for ub.prop-map .
DEFINE BUTTON b-dt-code
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 3"
     SIZE 3 BY 1.
DEFINE BUTTON b-dtm-code
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 3"
     SIZE 3 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-host
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON b-node-code
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 3"
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
DEFINE VARIABLE CB-obj-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEMS "","Item 1","Item 2"
     DROP-DOWN-LIST
     SIZE 11 BY 1
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE f-dt-code AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Код среза"
     VIEW-AS FILL-IN NATIVE
     SIZE 8.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-dtm-code AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Код объ-та"
     VIEW-AS FILL-IN NATIVE
     SIZE 8.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-dtm-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 72.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-high-character AS CHARACTER FORMAT "X(256)":U
     LABEL "Верхняя граница"
     VIEW-AS FILL-IN
     SIZE 27.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-high-date AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "Верхняя граница"
     VIEW-AS FILL-IN
     SIZE 27.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-high-decimal AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Верхняя граница"
     VIEW-AS FILL-IN
     SIZE 27.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-high-integer AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
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
DEFINE VARIABLE f-low-character AS CHARACTER FORMAT "X(256)":U
     LABEL "Нижняя граница"
     VIEW-AS FILL-IN
     SIZE 27.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-low-date AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "Нижняя граница"
     VIEW-AS FILL-IN
     SIZE 27.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-low-decimal AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Нижняя граница"
     VIEW-AS FILL-IN
     SIZE 27.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-low-integer AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Нижняя граница"
     VIEW-AS FILL-IN
     SIZE 27.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-node-code AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Код св-ва"
     VIEW-AS FILL-IN NATIVE
     SIZE 8.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-node-label AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 72.5 BY 1
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
     VIEW-AS FILL-IN NATIVE
     SIZE 31.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE rs-cond AS CHARACTER INITIAL ">"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "=", "=",
">", ">",
"<", "<",
">=", ">=",
"<=", "<="
     SIZE 30.5 BY 1 NO-UNDO.
DEFINE VARIABLE RS-range AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Глобально", "global",
"Фирма", "firm",
"Объект", "object"
     SIZE 36 BY 1 NO-UNDO.
DEFINE VARIABLE f-high-logical AS LOGICAL INITIAL no
     LABEL "Верхняя граница"
     VIEW-AS TOGGLE-BOX
     SIZE 27.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-low-logical AS LOGICAL INITIAL no
     LABEL "Нижняя граница"
     VIEW-AS TOGGLE-BOX
     SIZE 27.5 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1 WIDGET-ID 76
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     f-dtm-code AT ROW 2.6 COL 1.5 WIDGET-ID 34
     b-dtm-code AT ROW 2.6 COL 22 WIDGET-ID 32
     f-dtm-name AT ROW 2.6 COL 25 NO-LABEL WIDGET-ID 30
     f-dt-code AT ROW 3.6 COL 2.5 WIDGET-ID 36
     b-dt-code AT ROW 3.6 COL 22 WIDGET-ID 38
     f-sum-id AT ROW 3.6 COL 25 NO-LABEL WIDGET-ID 40
     f-node-code AT ROW 4.6 COL 2.5 WIDGET-ID 44
     b-node-code AT ROW 4.6 COL 22 WIDGET-ID 42
     f-node-label AT ROW 4.6 COL 25 NO-LABEL WIDGET-ID 46
     RS-range AT ROW 6.33 COL 25.5 NO-LABEL WIDGET-ID 58
     f-host-code AT ROW 7.67 COL 12 COLON-ALIGNED WIDGET-ID 54
     B-host AT ROW 7.67 COL 22 WIDGET-ID 48
     CB-obj-type AT ROW 9.17 COL 1.5 NO-LABEL WIDGET-ID 52
     f-obj-code AT ROW 9.17 COL 12 COLON-ALIGNED NO-LABEL WIDGET-ID 56
     B-obj AT ROW 9.17 COL 22 WIDGET-ID 50
     f-low-decimal AT ROW 10.6 COL 19.5 COLON-ALIGNED WIDGET-ID 68
     f-low-logical AT ROW 10.6 COL 21.5 WIDGET-ID 90
     f-low-date AT ROW 10.6 COL 19.5 COLON-ALIGNED WIDGET-ID 86
     f-low-integer AT ROW 10.6 COL 19.5 COLON-ALIGNED WIDGET-ID 80
     f-low-character AT ROW 10.6 COL 19.5 COLON-ALIGNED WIDGET-ID 82
     f-high-logical AT ROW 12.47 COL 21.5 WIDGET-ID 92
     f-high-integer AT ROW 12.6 COL 19.5 COLON-ALIGNED WIDGET-ID 78
     f-high-character AT ROW 12.6 COL 19.5 COLON-ALIGNED WIDGET-ID 84
     f-high-date AT ROW 12.6 COL 19.5 COLON-ALIGNED WIDGET-ID 88
     f-high-decimal AT ROW 12.6 COL 19.5 COLON-ALIGNED WIDGET-ID 66
     rs-cond AT ROW 14.33 COL 21.5 NO-LABEL WIDGET-ID 70
     F-host-name AT ROW 7.67 COL 24 COLON-ALIGNED NO-LABEL WIDGET-ID 62
     F-obj-name AT ROW 9.17 COL 24 COLON-ALIGNED NO-LABEL WIDGET-ID 64
     SPACE(15.99) SKIP(7.38)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор свойств ДК"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       f-high-character:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-high-date:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-high-decimal:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-high-integer:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-host-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-low-character:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-low-date:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-low-decimal:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-low-integer:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-obj-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  assign
  p-dtm-code  = f-dtm-code
  p-dt-code   = f-dt-code
  p-node-code = f-node-code
  p-host-code = f-host-code
  p-obj-type  = cb-obj-type
  p-obj-code  = f-obj-code
  p-value-character-low = f-low-character
  p-value-character-high = f-high-character
  p-value-date-low = f-low-date
  p-value-date-high = f-high-date
  p-value-decimal-low = f-low-decimal
  p-value-decimal-high = f-high-decimal
  p-value-integer-low = f-low-integer
  p-value-integer-high = f-high-integer
  p-value-logical-low = f-low-logical
  p-value-logical-high = f-high-logical
  p-cond = rs-cond
  p-ok = YES
  .
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-dt-code IN FRAME Dialog-Frame
DO:
DEFINE variable v-ref-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-ref FOR ub.prop-ref.
if f-dtm-code = ?
or f-dtm-code = 0
then do:
  message
  "Не выбран объект-операнд"
  view-as alert-box error .
  undo, return no-apply.
end.
run ref/proprefs.w (
                input parparentproc
              ,input 'b-sel'
              ,input (if f-dtm-code = ?
                      then 'dis-card-property':U
                      else "dtm-code")
              ,input (if f-dtm-code = ? then 0 else f-dtm-code)
              ,input '':U
              ,input '':U
              ,input-output  v-ref-list) no-error.
if error-status:error or v-ref-list = '':u then do:
  assign
  f-dt-code = ?
  f-sum-id = '':U.
  DISPLAY
  f-sum-id
  f-dt-code
  WITH FRAME Dialog-Frame.
  return.
end.
find first buf_prop-ref no-lock where
          recid(buf_prop-ref) = integer(v-ref-list) no-error.
if not available buf_prop-ref then return.
if buf_prop-ref.dt-code = f-dt-code then return no-apply.
ASSIGN
f-dt-code = buf_prop-ref.dt-code
f-sum-id = buf_prop-ref.sum-id.
DISPLAY
f-sum-id
f-dt-code
WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF b-dtm-code IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
 run rul/prop-head-s.w ( INPUT parparentproc
                         ,INPUT "b-sel"
                         ,input "general-view"
                         ,input 'dc-prop':U
                         ,input-output v-rid-list ) NO-ERROR.
 IF ERROR-STATUS:error OR v-rid-list = '':U THEN DO:
    UNDO, RETURN NO-APPLY.
 END.
 FIND FIRST buf_prop-head NO-LOCK WHERE
           recid(buf_prop-head) = INTEGER(v-rid-list) NO-ERROR.
 IF NOT AVAILABLE buf_prop-head  THEN DO:
    assign
    f-dt-code = ?
    f-sum-id = '':U
    f-dtm-code = ?
    f-dtm-name = '':U
    f-node-code = ?
    f-node-label = '':U
    .
    DISABLE
    b-node-code
    WITH FRAME Dialog-Frame.
    DISPLAY
    f-sum-id
    f-dtm-code
    f-dtm-name
    f-dt-code
    f-node-code
    f-node-label
    WITH FRAME Dialog-Frame.
   RETURN.
 END.
 if buf_prop-head.dtm-code = f-dtm-code then return no-apply.
 assign
 f-dtm-code = buf_prop-head.dtm-code
 f-dtm-name = buf_prop-head.prop-label
 .
 display
 f-dtm-code
 f-dtm-name
 with frame Dialog-Frame .
 ENABLE
 b-node-code
 WITH FRAME Dialog-Frame.
 RUN enable-disable-rs-range IN THIS-PROCEDURE.
END.
ON CHOOSE OF B-host IN FRAME Dialog-Frame
DO:
  IF f-dtm-code = ?
  OR f-dtm-code = 0 THEN DO:
    MESSAGE
    "Не выбран объект-операнд"
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN NO-APPLY.
  END.
  run proc-b-host IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-node-code IN FRAME Dialog-Frame
DO:
DEFINE variable v-ref-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-map FOR ub.prop-map.
IF f-dtm-code = ?
OR f-dtm-code = 0  THEN DO:
  MESSAGE
  "Не выбран объект-операнд"
  VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN NO-APPLY.
END.
run rul/prop-map-s.w (
                input parparentproc
              ,input 'b-sel'
              ,input "dtm-code"
              ,input f-dtm-code
              ,input-output  v-ref-list) no-error.
if error-status:error or v-ref-list = '':u then do:
  assign
  f-node-code = ?
  f-node-label = '':U.
  DISPLAY
  f-node-code
  f-node-label
  WITH FRAME Dialog-Frame.
  return.
end.
find first buf_prop-map no-lock where
          recid(buf_prop-map) = integer(v-ref-list) no-error.
if not available buf_prop-map then return.
if buf_prop-map.dtm-code = f-dtm-code
AND buf_prop-map.node-code = f-node-code then return no-apply.
ASSIGN
f-node-code = buf_prop-map.node-code
f-node-label = buf_prop-map.node-label.
DISPLAY
f-node-code
f-node-label
WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF B-obj IN FRAME Dialog-Frame
DO:
IF f-dtm-code = ?
OR f-dtm-code = 0 THEN DO:
  MESSAGE
  "Не выбран объект-операнд"
  VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN NO-APPLY.
END.
  run proc-b-obj IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON VALUE-CHANGED OF RS-range IN FRAME Dialog-Frame
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
         f-obj-name = '':U
         .
         DISABLE
         b-host
         b-obj
         WITH FRAME Dialog-Frame.
         DISPLAY
         f-host-code
         f-host-name
         cb-obj-type
         f-obj-code
         f-obj-name
         WITH FRAME Dialog-Frame.
      END.
      WHEN 'фирма':U THEN DO:
          ASSIGN
          cb-obj-type = '':U
          f-obj-code = 0
          f-obj-name = '':U.
          DISABLE
          b-obj
          WITH FRAME Dialog-Frame.
          DISPLAY
          f-host-code
          f-host-name
          cb-obj-type
          f-obj-code
          f-obj-name
          WITH FRAME Dialog-Frame.
          ENABLE
          b-host
          WITH FRAME Dialog-Frame.
      END.
      WHEN 'объект':U THEN DO:
          ASSIGN
          f-host-code = 0
          f-host-name = '':U
          cb-obj-type = '':U
          f-obj-code = 0
          f-obj-name = '':U.
          DISABLE
          b-host
          WITH FRAME Dialog-Frame.
          DISPLAY
          f-host-code
          f-host-name
          cb-obj-type
          f-obj-code
          f-obj-name
          WITH FRAME Dialog-Frame.
          ENABLE
          b-obj
          WITH FRAME Dialog-Frame.
      END.
  END CASE.
END.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if p-dtm-code <> ? then do:
    FIND FIRST buf_prop-head NO-LOCK WHERE
            buf_prop-head.dtm-code = p-dtm-code NO-ERROR.
    IF NOT AVAILABLE buf_prop-head THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description SKIP
        "Неверное значение параметра p-dtm-code" p-dtm-code SKIP
        "Нет объекта-операнда c кодом"  p-dtm-code
        VIEW-AS ALERT-BOX.
        UNDO, RETURN ERROR.
    END.
  end.
  if p-dt-code <> ? then do:
    FIND FIRST buf_prop-ref NO-LOCK WHERE
              buf_prop-ref.dt-code = p-dt-code NO-ERROR.
    IF NOT AVAILABLE buf_prop-ref THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description SKIP
        "Неверное значение параметра p-dt-code" p-dt-code SKIP
        "Нет среза c кодом"  p-dt-code
        VIEW-AS ALERT-BOX.
        UNDO, RETURN ERROR.
    END.
    if p-dtm-code = ? then do:
      p-dtm-code = buf_prop-ref.dtm-code .
    end.
    else do:
      if buf_prop-ref.dtm-code <> p-dtm-code then do:
        MESSAGE
        vss-workfile vss-revision vss-description SKIP
        "Неверное значение параметра p-dt-code" p-dt-code SKIP
        "Срез c кодом"  p-dt-code "принадлежит объекту-операнду" buf_prop-ref.dtm-code skip
        "а код объекта-операнда (p-dtm-code) = " p-dtm-code
        VIEW-AS ALERT-BOX.
        UNDO, RETURN ERROR.
      end.
    end.
    if p-node-code <> ?
    then do:
      find first buf_prop-map no-lock where
                buf_prop-map.dtm-code = p-dtm-code
            and buf_prop-map.node-code = p-node-code no-error.
      if not available buf_prop-map then do:
        MESSAGE
        vss-workfile vss-revision vss-description SKIP
        "Неверное значение параметра p-node-code" p-node-code SKIP
        substitute("Не найдейно свойство &1 для объекта-операнда &2"
                    ,p-node-code
                    ,p-dtm-code) skip
        VIEW-AS ALERT-BOX.
        UNDO, RETURN ERROR.
      end.
    end.
  end.
  run Myenable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable-disable-rs-range :
DEFINE VARIABLE v-range AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
v-range = "global" + chr(4) + 'фирма':U + chr(4) + 'объект':U.
ASSIGN
f-host-code = 0
cb-obj-type = '':U
f-obj-code = 0
f-host-name = '':U
f-obj-name = '':U
.
DISPLAY
f-host-code
cb-obj-type
f-obj-code
f-host-name
f-obj-name
WITH FRAME Dialog-Frame.
ENABLE
b-host
b-obj
WITH FRAME Dialog-Frame.
FIND FIRST buf_prop-head NO-LOCK WHERE
         buf_prop-head.dtm-code = f-dtm-code NO-ERROR.
if available buf_prop-head then do:
  if buf_prop-head.storage-place = '':U
  or buf_prop-head.storage-place = chr(63)
  or buf_prop-head.storage-place = ? then do:
    rs-range:disable(radio-label("global", rs-range:radio-buttons)) IN FRAME Dialog-Frame.
    entry(lookup("global", v-range, chr(4)), v-range,  chr(4)) = '':U.
  end.
  if buf_prop-head.storage-place-host = '':U
  or buf_prop-head.storage-place-host = chr(63)
  or buf_prop-head.storage-place-host = ? then do:
    rs-range:disable(radio-label('фирма':U, rs-range:radio-buttons))  IN FRAME Dialog-Frame.
    DISABLE b-host WITH FRAME Dialog-Frame.
    entry(lookup('фирма':U, v-range, chr(4)), v-range,  chr(4)) = '':U.
  end.
  if buf_prop-head.storage-place-obj = '':U
  or buf_prop-head.storage-place-obj = chr(63)
  or buf_prop-head.storage-place-obj = ? then do:
    rs-range:disable(radio-label('объект':U, rs-range:radio-buttons))  IN FRAME Dialog-Frame.
    DISABLE b-obj WITH FRAME Dialog-Frame.
    entry(lookup('объект':U, v-range, chr(4)), v-range,  chr(4)) = '':U.
  end.
  v-range = REPLACE(v-range, chr(4) + chr(4), chr(4)).
  rs-range = ENTRY(1, v-range, chr(4)).
  DISPLAY rs-range WITH FRAME Dialog-Frame.
end.
ELSE DO:
  rs-range:disable(radio-label("global", rs-range:radio-buttons)).
  rs-range:disable(radio-label('фирма':U, rs-range:radio-buttons)).
  rs-range:disable(radio-label('объект':U, rs-range:radio-buttons)).
END.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-dtm-code f-dtm-name f-dt-code f-sum-id f-node-code f-node-label
          RS-range f-host-code CB-obj-type f-obj-code f-low-decimal
          f-low-logical f-low-date f-low-integer f-low-character f-high-logical
          f-high-integer f-high-character f-high-date f-high-decimal rs-cond
          F-host-name F-obj-name
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit B-Help b-dtm-code b-dt-code RS-range CB-obj-type
         f-low-decimal f-low-logical f-low-date f-low-integer f-low-character
         f-high-logical f-high-integer f-high-character f-high-date
         f-high-decimal rs-cond F-host-name F-obj-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
define buffer buf_clients for ub.clients.
ASSIGN
rs-range:RADIO-BUTTONS IN FRAME Dialog-Frame  = "Объекты" + chr(44) + 'объект':U + chr(44) +
                        "Фирмы" + chr(44) + 'фирма':U + chr(44) +
                        "Глобально" + chr(44) + "global"
CB-obj-type:list-items = '':U + chr(44) + 'маг':U + chr(44) + 'скл':U
rs-range = "global"
f-dtm-code = p-dtm-code
f-dt-code = p-dt-code
f-node-code = p-node-code
.
if available buf_prop-head then do:
  assign
  f-dtm-name = buf_prop-head.prop-name
  .
end.
if available buf_prop-head then do:
  assign
  f-sum-id = buf_prop-ref.sum-id
  .
end.
if available buf_prop-map then do:
  assign
  f-node-label = buf_prop-map.node-label
  .
end.
rs-cond = p-cond.
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
    WITH FRAME Dialog-Frame.
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
        WITH FRAME Dialog-Frame.
    END.
END.
ASSIGN
CB-obj-type = p-obj-type
f-obj-code = p-obj-code
.
IF f-obj-code > 0 THEN DO:
    ASSIGN
    rs-range = 'объект':U.
END.
ELSE do:
   IF f-host-code > 0 THEN DO:
     ASSIGN
     rs-range = 'фирма':U.
   END.
   ASSIGN
   rs-range ="global":U.
END.
display
f-dtm-code
f-dtm-name
f-dt-code
f-sum-id
f-node-code
f-node-label
with frame Dialog-Frame .
ENABLE
b-quit
b-exit
B-Help
b-dtm-code
b-dt-code
b-node-code
rs-cond
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
RUN enable-disable-rs-range IN THIS-PROCEDURE.
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
      WITH FRAME Dialog-Frame.
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
      WITH FRAME Dialog-Frame.
  end.
END PROCEDURE.
