DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-dtm-code AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-sum-id AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-dt-code AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-node-code AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-emitent-host-code AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-type AS character NO-UNDO.
DEFINE INPUT PARAMETER p-d-card AS character NO-UNDO.
DEFINE INPUT PARAMETER p-host-code AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code AS integer NO-UNDO.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE TEMP-TABLE temp-dis-card-property NO-UNDO LIKE ub.dis-card-property
field rw-option as character
field prop-label as character
field node-label as character
field data-type as character
field range as integer
INDEX attrc is
UNIQUE PRIMARY
prop-label
node-label
dt-code
host-code
obj-type
obj-code
INDEX attrcl is UNIQUE
dt-code
node-code
host-code
obj-type
obj-code
.
DEFINE INPUT-OUTPUT PARAMETER TABLE FOR temp-dis-card-property.
DEFINE OUTPUT PARAMETER p-setted AS LOGICAL NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Топливо для ДК".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable is-elved-chr as character no-undo .
define variable par-type as character no-undo .
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-ref for ub.prop-ref.
DEFINE BUTTON B-cdpay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-gds
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE f-car-brand AS CHARACTER FORMAT "X(256)":U
     LABEL "Марка ТС"
     VIEW-AS FILL-IN
     SIZE 40 BY 1.07 NO-UNDO.
DEFINE VARIABLE f-car-reg-number AS CHARACTER FORMAT "X(40)":U
     LABEL "Гос.рег.знак"
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.
DEFINE VARIABLE f-cdpay-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Тип касс. пл-жа"
     VIEW-AS FILL-IN NATIVE
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE f-cdpay-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 62.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-gds-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Код товара"
     VIEW-AS FILL-IN NATIVE
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE f-gds-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 62.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-limit AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "Лимит кредита по данному топливу (сумма)"
     VIEW-AS FILL-IN
     SIZE 30 BY 1 NO-UNDO.
DEFINE VARIABLE f-limit-l AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "Лимит кредита по данному топливу (кол-во)"
     VIEW-AS FILL-IN
     SIZE 30 BY 1 NO-UNDO.
DEFINE VARIABLE f-quota AS DECIMAL FORMAT ">>>,>>>,>>9.99":U INITIAL 0
     LABEL "Квота на топливо за период времени"
     VIEW-AS FILL-IN
     SIZE 21 BY 1.07 NO-UNDO.
DEFINE VARIABLE rs-account-type AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Безлимитный бензиновый", 7,
"Безлимитный денежный", 6,
"Лимитный бензиновый", 5,
"Неопределено", 0
     SIZE 34.5 BY 5 NO-UNDO.
DEFINE VARIABLE rs-limit-type AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Лимит в валюте продаж", "sum",
"Лимит по кол-ву топлива", "qnty"
     SIZE 40.5 BY 2.13 NO-UNDO.
DEFINE VARIABLE RS-quota-period AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Месяц", "month",
"День", "day"
     SIZE 27 BY 1.77 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     f-gds-code AT ROW 2.5 COL 19 COLON-ALIGNED
     f-gds-name AT ROW 2.5 COL 35 COLON-ALIGNED NO-LABEL
     B-gds AT ROW 2.6 COL 32.5
     B-cdpay AT ROW 3.67 COL 32.5 WIDGET-ID 2
     f-cdpay-code AT ROW 3.77 COL 19 COLON-ALIGNED
     f-cdpay-name AT ROW 3.77 COL 35 COLON-ALIGNED NO-LABEL
     rs-account-type AT ROW 5.5 COL 63.5 NO-LABEL
     f-car-brand AT ROW 5.77 COL 19 COLON-ALIGNED
     f-car-reg-number AT ROW 7.33 COL 19 COLON-ALIGNED
     rs-limit-type AT ROW 8.5 COL 21 NO-LABEL
     f-limit AT ROW 11 COL 46.5 COLON-ALIGNED
     f-limit-l AT ROW 12.5 COL 46.5 COLON-ALIGNED
     f-quota AT ROW 14 COL 38 COLON-ALIGNED
     RS-quota-period AT ROW 14 COL 71 NO-LABEL
     SPACE(1.69) SKIP(0.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Топливо по ДК"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       f-cdpay-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-cdpay-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-gds-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-gds-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-cdpay IN FRAME Dialog-Frame
DO:
DEFINE variable v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
IF f-cdpay-code <> 0 THEN DO:
   FIND FIRST buf_cash-pay NO-LOCK WHERE
             buf_cash-pay.cdpay-code = f-cdpay-code
       AND buf_cash-pay.curr-code = 0 NO-ERROR.
   IF AVAILABLE buf_cash-pay THEN DO:
       ASSIGN
           v-rid-list = STRING(RECID(buf_cash-pay)).
   END.
END.
run ref/cashpays.w ( INPUT parparentproc
                    ,INPUT "b-sel"
                    ,input 'все':U
                    ,INPUT v-cntxt-host-code-obj
                     ,INPUT v-cntxt-obj-type
                     ,INPUT v-cntxt-obj-code
                     ,OUTPUT v-rid-list) NO-ERROR.
IF NOT ERROR-STATUS:ERROR THEN DO:
  FIND FIRST buf_cash-pay NO-LOCK WHERE
            recid(buf_cash-pay) = INTEGER(v-rid-list) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  ASSIGN
  f-cdpay-code = buf_cash-pay.cdpay-code
  f-cdpay-name = buf_cash-pay.obj-name
  .
END.
DISPLAY
f-cdpay-code
f-cdpay-name
WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:error THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-gds IN FRAME Dialog-Frame
DO:
DEFINE variable v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_goods FOR ub.goods.
   run ref/petrlref.p ( INPUT parparentproc
                  ,INPUT "b-sel"
                  ,OUTPUT v-rid-list ) NO-ERROR.
IF NOT ERROR-STATUS:ERROR THEN DO:
  FIND FIRST buf_goods NO-LOCK WHERE
            recid(buf_goods) = INTEGER(v-rid-list) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  ASSIGN
  f-gds-code = buf_goods.gds-code
  f-gds-name = buf_goods.gds-name
  .
END.
DISPLAY
f-gds-code
f-gds-name
WITH FRAME Dialog-Frame.
END.
ON VALUE-CHANGED OF rs-limit-type IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-limit-type.
  CASE rs-limit-type:
      WHEN "sum" THEN DO:
        DISPLAY
        f-limit
        WITH FRAME Dialog-Frame.
        ENABLE
        f-limit when p-mode <> 'ПРОСМОТР':U
        WITH FRAME Dialog-Frame.
        HIDE
        f-limit-l
        IN FRAME Dialog-Frame.
      END.
      WHEN "qnty" THEN DO:
        DISPLAY
        f-limit-l
        WITH FRAME Dialog-Frame.
        ENABLE
        f-limit-l when p-mode <> 'ПРОСМОТР':U
        WITH FRAME Dialog-Frame.
        HIDE
        f-limit
        IN FRAME Dialog-Frame.
      END.
  END CASE.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  IF p-mode <> 'ДОБАВЛЕНИЕ':U
  AND p-mode <> 'ИЗМЕНЕНИЕ':U
  AND p-mode <> 'ПРОСМОТР':U THEN DO:
    MESSAGE
    substitute("Неверное значение параметра p-mode=&1", p-mode)
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-elved'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output is-elved-chr
  ,output par-type
  ) no-error .
  if error-status:error
  or logical(is-elved-chr) = no then do:
    message
    "В Вашей конфигурации нельзя работать с этим свойством ДК," skip
    "так как не включен конфигурационный параметр is-elved"
    view-as alert-box .
    undo, return error .
  end.
  find first buf_prop-head no-lock where
            buf_prop-head.dtm-code = p-dtm-code.
  find first buf_prop-ref no-lock where
          buf_prop-ref.dtm-code = p-dtm-code
      and buf_prop-ref.dt-code = p-dt-code.
  RUN Myenable IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-gds-code f-gds-name f-cdpay-code f-cdpay-name rs-account-type
          f-car-brand f-car-reg-number rs-limit-type f-limit f-limit-l f-quota
          RS-quota-period
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help B-gds B-cdpay rs-account-type f-car-brand
         f-car-reg-number rs-limit-type f-limit f-limit-l f-quota
         RS-quota-period
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
DEFINE BUFFER buf_dis-card-type FOR ub.dis-card-type.
IF p-sum-id <> "":U THEN DO:
  FIND FIRST buf_goods NO-LOCK WHERE
            buf_goods.gds-code = integer(substring(p-sum-id, LENGTH("petrol-") + 1)) NO-ERROR.
  IF AVAILABLE buf_goods THEN DO:
     ASSIGN
     f-gds-code = buf_goods.gds-code
     f-gds-name = buf_goods.gds-name
     .
  END.
END.
FOR EACH temp-dis-card-property where
       temp-dis-card-property.dtm-code = p-dtm-code
    and temp-dis-card-property.sum-id = p-sum-id:
   CASE temp-dis-card-property.node-code:
     WHEN 1 THEN DO:
       f-car-reg-number = temp-dis-card-property.property-value-character.
     END.
     WHEN 2 THEN DO:
        f-car-brand = temp-dis-card-property.property-value-character.
     END.
     WHEN 3 THEN DO:
        rs-limit-type = temp-dis-card-property.property-value-character.
     END.
     WHEN 4 THEN DO:
        f-limit = temp-dis-card-property.property-value-decimal.
     END.
     WHEN 5 THEN DO:
        f-limit-l = temp-dis-card-property.property-value-decimal.
     END.
     WHEN 6 THEN DO:
        rs-quota-period = temp-dis-card-property.property-value-character.
     END.
     WHEN 7 THEN DO:
       f-quota = temp-dis-card-property.property-value-decimal.
     END.
     WHEN 8 THEN DO:
       IF p-mode = 'ДОБАВЛЕНИЕ':U
       AND p-sum-id = 'petrol-':U     THEN DO:
         temp-dis-card-property.property-value-integer = 6.
       END.
       rs-account-type = temp-dis-card-property.property-value-integer.
     END.
     WHEN 9 THEN DO:
       FIND FIRST buf_cash-pay NO-LOCK WHERE
                   buf_cash-pay.cdpay-code = temp-dis-card-property.property-value-integer
               and buf_cash-pay.curr-code = 0 NO-ERROR.
        IF AVAILABLE buf_cash-pay THEN DO:
            ASSIGN
            f-cdpay-code = buf_cash-pay.cdpay-code
            f-cdpay-name = buf_cash-pay.obj-name
            .
        END.
    END.
  END CASE.
END.
IF p-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
  ASSIGN
  rs-limit-type = "sum".
  FIND FIRST buf_Dis-card-type NO-LOCK WHERE
        buf_dis-card-type.emitent-host-code = p-emitent-host-code
    AND   buf_dis-card-type.TYPE = p-type
  AND buf_dis-card-type.host-code = 0
  AND buf_Dis-card-type.obj-type = '':U
  AND buf_Dis-card-type.obj-code = 0 NO-ERROR.
  IF NOT AVAILABLE buf_dis-card-type THEN DO:
    MESSAGE
    "Не определен тип ДК" SKIP
      "Невозможно задать свойство"
      VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
  IF buf_dis-card-type.dflt-debet-card  THEN DO:
    IF buf_dis-card-type.pay-code > 0  THEN DO:
      FIND FIRST buf_cash-pay NO-LOCK WHERE
            buf_cash-pay.cdpay-code = buf_dis-card-type.pay-code
          AND buf_cash-pay.curr-code = 0 NO-ERROR.
      IF AVAILABLE buf_cash-pay THEN DO:
          ASSIGN
          f-cdpay-code = buf_cash-pay.cdpay-code
          f-cdpay-name = buf_cash-pay.obj-name
          .
      END.
    END.
  END.
END.
DISPLAY
f-gds-code
f-gds-name
f-cdpay-code
f-cdpay-name
f-car-brand
f-car-reg-number
rs-limit-type
f-limit
f-limit-l
rs-quota-period
f-quota
rs-account-type
WITH FRAME Dialog-Frame.
ENABLE
B-exit WHEN p-mode <> 'ПРОСМОТР':U
b-quit
B-Help
f-car-reg-number WHEN p-mode <> 'ПРОСМОТР':U
f-car-brand WHEN p-mode <> 'ПРОСМОТР':U
f-limit WHEN p-mode <> 'ПРОСМОТР':U
f-limit-l WHEN p-mode <> 'ПРОСМОТР':U
rs-limit-type WHEN p-mode <> 'ПРОСМОТР':U
f-quota WHEN p-mode <> 'ПРОСМОТР':U
rs-account-type WHEN p-mode <> 'ПРОСМОТР':U
rs-quota-period WHEN p-mode <> 'ПРОСМОТР':U
b-cdpay WHEN p-mode <> 'ПРОСМОТР':U
WITH FRAME Dialog-Frame.
rs-account-type:disable(radio-label(string(0), RS-account-type:radio-buttons)).
VIEW FRAME Dialog-Frame.
IF p-mode = 'ПРОСМОТР':U  THEN DO:
  ASSIGN
  b-quit:LABEL = "&Выход"
  b-quit:COLUMN = 1
  .
  HIDE
  b-exit
  IN FRAME Dialog-Frame.
END.
APPLY "VALUE-CHANGED" to rs-limit-type.
END PROCEDURE.
PROCEDURE proc-save :
DEFINE BUFFER buf_prop-map FOR ub.prop-map.
ASSIGN
FRAME Dialog-Frame
rs-limit-type
f-gds-code
f-car-brand
f-car-reg-number
f-limit
f-limit-l
rs-quota-period
f-quota
rs-account-type
.
IF rs-account-type <> 6
AND p-sum-id = 'petrol-':U     THEN do:
  MESSAGE
  substitute("Если огрaничения вида топлива нет, то можно выбрать только &1"
             ,radio-label ( INPUT STRING(6)
                            ,INPUT rs-account-type:RADIO-BUTTONS IN FRAME Dialog-Frame)
             )
  VIEW-AS ALERT-BOX ERROR.
UNDO, RETURN ERROR.
END.
IF rs-account-type = 6
AND p-sum-id <> 'petrol-':U     THEN do:
  MESSAGE
  substitute("Если есть ограничения вида топлива, то нельзя выбрать &1"
             ,radio-label ( INPUT STRING(6)
                            ,INPUT rs-account-type:RADIO-BUTTONS IN FRAME Dialog-Frame)
             )
  VIEW-AS ALERT-BOX ERROR.
UNDO, RETURN ERROR.
END.
IF f-limit = ?
or f-limit-l = ?
OR f-quota = ?
THEN DO:
  MESSAGE
  "Не задано значение лимита и/или квоты по топливу"
  view-as ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
END.
FOR EACH buf_prop-map NO-LOCK WHERE
        buf_prop-map.dtm-code = p-dtm-code
     and buf_prop-map.node-code > 0:
  FIND FIRST temp-dis-card-property WHERE
            temp-dis-card-property.d-card = p-d-card
      AND   temp-dis-card-property.dt-code = p-dt-code
      AND   temp-dis-card-property.node-code = buf_prop-map.node-code
      AND   temp-dis-card-property.host-code = p-host-code
      AND   temp-dis-card-property.obj-type = p-obj-type
      AND   temp-dis-card-property.obj-code = p-obj-code NO-ERROR.
  IF NOT AVAILABLE temp-dis-card-property THEN DO:
    CREATE temp-dis-card-property.
    ASSIGN
    temp-dis-card-property.d-card = p-d-card
    temp-dis-card-property.dt-code = p-dt-code
    temp-dis-card-property.dtm-code = p-dtm-code
    temp-dis-card-property.sum-id = p-sum-id
    temp-dis-card-property.node-code = buf_prop-map.node-code
    temp-dis-card-property.host-code = p-host-code
    temp-dis-card-property.obj-type = p-obj-type
    temp-dis-card-property.obj-code = p-obj-code
    temp-dis-card-property.prop-label = buf_prop-head.prop-label
    temp-dis-card-property.node-label = buf_prop-map.node-label
    temp-dis-card-property.data-type = buf_prop-map.node-value-type
    .
  END.
END.
FOR EACH temp-dis-card-property
   where temp-dis-card-property.d-card = p-d-card
and temp-dis-card-property.dtm-code = p-dtm-code
and temp-dis-card-property.dt-code = p-dt-code
   :
   CASE temp-dis-card-property.node-code:
     WHEN 1 THEN DO:
       temp-dis-card-property.property-value-character = f-car-reg-number.
     END.
     WHEN 2 THEN DO:
       temp-dis-card-property.property-value-character = f-car-brand.
     END.
     WHEN 3 THEN DO:
        temp-dis-card-property.property-value-character = rs-limit-type.
     END.
     WHEN 4 THEN DO:
        temp-dis-card-property.property-value-decimal = f-limit .
     END.
     WHEN 5 THEN DO:
        temp-dis-card-property.property-value-decimal = f-limit-l .
     END.
     WHEN 6 THEN DO:
        temp-dis-card-property.property-value-character = rs-quota-period .
     END.
     WHEN 7 THEN DO:
       temp-dis-card-property.property-value-decimal = f-quota .
     END.
     WHEN 8 THEN DO:
       temp-dis-card-property.property-value-integer = rs-account-type .
     END.
     WHEN 9 THEN DO:
         temp-dis-card-property.property-value-integer = f-cdpay-code.
    END.
  END CASE.
END.
ASSIGN
p-setted = YES
.
END PROCEDURE.
