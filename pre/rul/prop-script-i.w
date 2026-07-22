DEFINE BUFFER locked_prop-script FOR ub.prop-script.
DEFINE TEMP-TABLE tt-prop-script NO-UNDO LIKE ub.prop-script.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-dtm-code AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-language AS character NO-UNDO.
DEFINE INPUT PARAMETER p-script-name AS character NO-UNDO.
DEFINE INPUT PARAMETER p-revis-id AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init " ‡ÚÓ˜Í‡ prop-script".
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
define variable v-is-copy as logical no-undo .
DEFINE BUFFER first_prop-script FOR ub.prop-script.
DEFINE BUFFER buf_ruledict FOR ub.ruledict.
DEFINE BUTTON b-copy
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&¬‚Ó‰"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "œÓÏÓ&˘¸"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-params
     LABEL "œ‡-˚"
     SIZE 10 BY 1.
DEFINE BUTTON b-prop-map
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON b-prop-map-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&ŒÚÏÂÌ‡"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE cb-object-type AS CHARACTER FORMAT "X(256)":U
     LABEL "“ËÔ Œ·˙ÂÍÚ"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 35 BY 1 NO-UNDO.
DEFINE VARIABLE f-label AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 95 BY 1.58 TOOLTIP "ÀÂÈ·Î" NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-prop-script SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     tt-prop-script.dtm-code AT ROW 1 COL 22 WIDGET-ID 2
          LABEL " Ó‰ Ó·˙."
          VIEW-AS FILL-IN NATIVE
          SIZE 7.5 BY 1
     tt-prop-script.class-dtm-code AT ROW 1 COL 48.5 COLON-ALIGNED WIDGET-ID 58
          LABEL " Ó‰ ÍÎ."
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     tt-prop-script.language AT ROW 1 COL 58 NO-LABEL WIDGET-ID 10
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "ABL", "ABL":U
          SIZE 5.5 BY 1.08
     tt-prop-script.revis_id AT ROW 1 COL 69.5 COLON-ALIGNED WIDGET-ID 44
          LABEL "¬ÂÒ."
          VIEW-AS FILL-IN NATIVE
          SIZE 5.5 BY 1
     b-params AT ROW 1 COL 78 WIDGET-ID 36
     B-Help AT ROW 1 COL 88
     tt-prop-script.script-name AT ROW 2.08 COL 1 NO-LABEL WIDGET-ID 54
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 95 BY 1.88 TOOLTIP "Õ‡Á‚‡ÌËÂ"
     b-copy AT ROW 2.33 COL 96.5 WIDGET-ID 50
     f-label AT ROW 3.92 COL 1 NO-LABEL WIDGET-ID 52
     b-prop-map AT ROW 4.21 COL 96.5 WIDGET-ID 46
     b-prop-map-2 AT ROW 5.54 COL 18.5 WIDGET-ID 48
     tt-prop-script.hidden_ AT ROW 5.54 COL 41 WIDGET-ID 56
          LABEL "—Í˚Ú˚È"
          VIEW-AS TOGGLE-BOX
          SIZE 18.5 BY 1
     tt-prop-script.documentation AT ROW 6.58 COL 1 NO-LABEL WIDGET-ID 6
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 1.88
     tt-prop-script.proc-type AT ROW 8.46 COL 12 COLON-ALIGNED WIDGET-ID 12
          LABEL "“ËÔ ÔÓˆ-˚" FORMAT "x(20)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 30.5 BY 1
     tt-prop-script.script-type AT ROW 8.46 COL 59.5 COLON-ALIGNED WIDGET-ID 16
          LABEL "“ËÔ ÒÍËÔÚ‡" FORMAT "X(20)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 35 BY 1
     cb-object-type AT ROW 9.46 COL 59.5 COLON-ALIGNED WIDGET-ID 42
     tt-prop-script.script-value-type AT ROW 9.54 COL 12 COLON-ALIGNED WIDGET-ID 18
          LABEL "«Ì‡˜-Â" FORMAT "X(20)"
          VIEW-AS COMBO-BOX INNER-LINES 7
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 30.5 BY 1
     tt-prop-script.signature AT ROW 10.58 COL 2 WIDGET-ID 22
          LABEL "—Ë„Ì-‡"
          VIEW-AS FILL-IN NATIVE
          SIZE 88 BY 1 TOOLTIP "◊ÚÓ·˚ Á‡·ÎÓÍ ‡‚ÚÓ ÙÓÏËÓ‚‡ÌËÂ Ì‡ÔË¯Ë ÒË„Ì‡ÚÛÛ Ò @ ‚ÔÂÂ‰Ë"
     tt-prop-script.script-head AT ROW 12.21 COL 1 NO-LABEL WIDGET-ID 20
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 2.92
     tt-prop-script.script-body AT ROW 15.92 COL 1 NO-LABEL WIDGET-ID 26
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 3.42
     tt-prop-script.script-foot AT ROW 20.21 COL 1 NO-LABEL WIDGET-ID 30
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98.5 BY 2.92
     "œÓ‰‚‡Î" VIEW-AS TEXT
          SIZE 7.5 BY .79 AT ROW 19.42 COL 1 WIDGET-ID 32
     "“ÂÎÓ" VIEW-AS TEXT
          SIZE 7.5 BY .79 AT ROW 15.13 COL 1 WIDGET-ID 28
     "√ÓÎÓ‚‡" VIEW-AS TEXT
          SIZE 7.5 BY .79 AT ROW 11.42 COL 1 WIDGET-ID 24
     "ŒÔËÒ‡ÌËÂ" VIEW-AS TEXT
          SIZE 17 BY 1 AT ROW 5.54 COL 1.5 WIDGET-ID 8
     SPACE(81.20) SKIP(16.68)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       tt-prop-script.script-foot:RETURN-INSERTED IN FRAME Dialog-Frame  = TRUE.
ASSIGN
       tt-prop-script.script-name:RETURN-INSERTED IN FRAME Dialog-Frame  = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-copy IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  DEFINE BUFFER buf_prop-script FOR ub.prop-script.
  run rul/prop-script-s.w (
                           input parparentproc
                          ,INPUT 'b-sel':U
                          ,INPUT "dtm-code"
                          ,INPUT '':U
                          ,INPUT tt-prop-script.dtm-code
                          ,INPUT "":U
                          ,INPUT "":U
                          ,INPUT-OUTPUT v-rid-list) NO-ERROR.
 IF ERROR-STATUS:ERROR OR v-rid-list = '':U THEN RETURN NO-APPLY.
 FIND FIRST buf_prop-script NO-LOCK WHERE
           recid(buf_prop-script) = INTEGER(v-rid-list).
 BUFFER-COPY buf_prop-script TO tt-prop-script.
 RUN MyEnable IN THIS-PROCEDURE ( input ' Œœ»–Œ¬¿Õ»≈':U) NO-ERROR .
END.
ON CHOOSE OF b-params IN FRAME Dialog-Frame
DO:
 DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  DEFINE BUFFER buf_ruledict-param FOR ub.ruledict-param.
  IF NOT AVAILABLE buf_ruledict  THEN DO:
    MESSAGE
    "≈˘Â ÓÚÒÛÚÒÚ‚ÛÂÚ ‚ ÒÎÓ‚‡Â"
    VIEW-AS ALERT-BOX.
    RETURN NO-APPLY.
  END.
  find first buf_ruledict-param no-lock where
            buf_ruledict-param.entry-id = buf_ruledict.entry-id no-error.
  if not available buf_ruledict-param then do:
    message
    "ÕÂÚ Ô‡‡ÏÂÚÓ‚!"
    view-as alert-box error .
    undo, return no-apply .
  end.
  run rul/ruledict-param-s.w ( INPUT parparentproc
                            ,input ?
                            ,INPUT '':U
                            ,INPUT "entry-id"
                            ,INPUT buf_ruledict.entry-id
                            ,input 'prop-script':U
                            ,INPUT-OUTPUT v-rid-list) NO-ERROR.
END.
ON CHOOSE OF b-prop-map IN FRAME Dialog-Frame
DO:
   DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-map FOR ub.prop-map.
    run rul/prop-map-s.w (
                           input parparentproc
                          ,INPUT 'b-sel':U
                          ,INPUT "dtm-code"
                          ,INPUT tt-prop-script.dtm-code
                          ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  IF v-rid-list = '':U THEN DO:
     RETURN NO-APPLY.
  END.
  FIND FIRST buf_prop-map NO-LOCK WHERE
            RECID(buf_prop-map) = INTEGER(v-rid-list) NO-ERROR.
  IF NOT AVAILABLE buf_prop-map THEN RETURN NO-APPLY.
  ASSIGN
  f-label = buf_prop-map.node-label.
  DISPLAY
  f-label
  WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF b-prop-map-2 IN FRAME Dialog-Frame
DO:
    DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
 DEFINE BUFFER buf_prop-map FOR ub.prop-map.
     run rul/prop-map-s.w (
                            input parparentproc
                           ,INPUT 'b-sel':U
                           ,INPUT "dtm-code"
                           ,INPUT tt-prop-script.dtm-code
                           ,INPUT-OUTPUT v-rid-list) NO-ERROR.
   IF v-rid-list = '':U THEN DO:
      RETURN NO-APPLY.
   END.
   FIND FIRST buf_prop-map NO-LOCK WHERE
             RECID(buf_prop-map) = INTEGER(v-rid-list) NO-ERROR.
   IF NOT AVAILABLE buf_prop-map THEN RETURN NO-APPLY.
   ASSIGN
   tt-prop-script.documentation = buf_prop-map.node-description.
   DISPLAY
   f-label
   WITH FRAME Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  IF p-mode = 'ƒŒ¡¿¬À≈Õ»≈':U THEN DO:
    FIND FIRST first_prop-script EXCLUSIVE-LOCK.
    CREATE tt-prop-script.
    ASSIGN
    tt-prop-script.LANGUAGE = "ABL"
    tt-prop-script.dtm-code = p-dtm-code.
  END.
  else do:
    IF p-mode = ' Œœ»–Œ¬¿Õ»≈':U THEN DO:
      v-is-copy = yes.
      p-mode = 'ƒŒ¡¿¬À≈Õ»≈':U.
      FIND FIRST first_prop-script EXCLUSIVE-LOCK.
      FIND FIRST first_prop-script EXCLUSIVE-LOCK.
      FIND FIRST LOCKED_prop-script no-lock WHERE
                LOCKED_prop-script.script-name = p-script-name
          AND LOCKED_prop-script.LANGUAGE = p-language
          AND LOCKED_prop-script.dtm-code = p-dtm-code
          AND LOCKED_prop-script.revis_id = p-revis-id
          .
      create tt-prop-script.
      buffer-copy locked_prop-script
      to tt-prop-script.
      release locked_prop-script.
    END.
    IF p-mode = '»«Ã≈Õ≈Õ»≈':U THEN DO:
      FIND FIRST LOCKED_prop-script EXCLUSIVE-LOCK WHERE
                LOCKED_prop-script.script-name = p-script-name
          AND LOCKED_prop-script.LANGUAGE = p-language
          AND LOCKED_prop-script.dtm-code = p-dtm-code
          AND LOCKED_prop-script.revis_id = p-revis-id
          .
      create tt-prop-script.
      buffer-copy locked_prop-script to tt-prop-script.
    END.
    IF p-mode = 'œ–Œ—ÃŒ“–':U THEN DO:
        FIND FIRST LOCKED_prop-script no-lock WHERE
                  LOCKED_prop-script.script-name = p-script-name
            AND LOCKED_prop-script.LANGUAGE = p-language
            AND LOCKED_prop-script.dtm-code = p-dtm-code
            AND LOCKED_prop-script.revis_id = p-revis-id.
      create tt-prop-script.
      buffer-copy locked_prop-script to tt-prop-script.
    END.
  end.
  RUN Myenable in THIS-PROCEDURE ( input p-mode).
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-prop-script SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY f-label cb-object-type
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-prop-script THEN
    DISPLAY tt-prop-script.dtm-code tt-prop-script.class-dtm-code
          tt-prop-script.language tt-prop-script.revis_id
          tt-prop-script.script-name tt-prop-script.hidden_
          tt-prop-script.documentation tt-prop-script.proc-type
          tt-prop-script.script-type tt-prop-script.script-value-type
          tt-prop-script.signature tt-prop-script.script-head
          tt-prop-script.script-body tt-prop-script.script-foot
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit tt-prop-script.dtm-code tt-prop-script.class-dtm-code
         tt-prop-script.language tt-prop-script.revis_id b-params B-Help
         tt-prop-script.script-name b-copy f-label b-prop-map b-prop-map-2
         tt-prop-script.hidden_ tt-prop-script.documentation
         tt-prop-script.proc-type tt-prop-script.script-type cb-object-type
         tt-prop-script.script-value-type tt-prop-script.signature
         tt-prop-script.script-head tt-prop-script.script-body
         tt-prop-script.script-foot
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
define input parameter p-mode as character no-undo .
define buffer bufcL_prop-script for ub.prop-script.
IF p-mode = '»«Ã≈Õ≈Õ»≈':U
OR p-mode = 'œ–Œ—ÃŒ“–':U
OR (p-mode = 'ƒŒ¡¿¬À≈Õ»≈':U and v-is-copy = yes)
THEN DO:
  FIND FIRST buf_Ruledict NO-LOCK WHERE
            buf_ruledict.entry-type  = 'prop-script':U
          and buf_ruledict.uniq-key-rec  = tt-prop-script.uniq-key-rec no-error.
  if available buf_ruledict then do:
    f-label = buf_ruledict.script-nl.
  end.
END.
if not available buf_ruledict
and (p-mode = '»«Ã≈Õ≈Õ»≈':U or (p-mode = 'ƒŒ¡¿¬À≈Õ»≈':U and v-is-copy = yes))
and lookup(tt-prop-script.proc-type,
          (
          'data-member':U + chr(44) +
          'property':U + chr(44) +
          'method':U + chr(44) +
          'constructor':U + chr(44) +
          'destructor':U)) > 0 then do:
  find first bufcl_prop-script no-lock where
            bufcl_prop-script.dtm-code = tt-prop-script.dtm-code
       and  bufcl_prop-script.language = tt-prop-script.language
       and  bufcl_prop-script.script-name  = entry(1, tt-prop-script.script-name, ":") no-error.
  if available bufcl_prop-script then do:
    FIND FIRST buf_Ruledict NO-LOCK WHERE
              buf_ruledict.entry-type  = 'prop-script':U
            and buf_ruledict.uniq-key-rec  = bufcl_prop-script.uniq-key-rec no-error.
    if available buf_ruledict then do:
      f-label = buf_ruledict.script-nl.
    end.
  end.
end.
ASSIGN
tt-prop-script.proc-type:LIST-ITEMS IN FRAME Dialog-Frame = 'procedure,function,extern,dll-entry,main,class,data-member,property,method,constructor,destructor':u
tt-prop-script.script-type:LIST-ITEMS IN FRAME Dialog-Frame = 'set,get,get-ifunction,get-set,find,define_b,define_tt,define_h,create,function,ifunction,variable':u
tt-prop-script.script-value-type:LIST-ITEMS IN FRAME Dialog-Frame = 'character,date,decimal,integer,logical':U + chr(44) +
                                                                      'handle':U + chr(44) +
                                                                      'void':U
cb-object-type:LIST-ITEMS IN FRAME Dialog-Frame = ",r-b,dis-card"
.
ASSIGN
cb-object-type = (if num-entries(tt-prop-script.script-value-type) > 1
                  then ENTRY(2, tt-prop-script.script-value-type)
                  else '':U)
tt-prop-script.script-value-type =ENTRY(1, tt-prop-script.script-value-type)
.
DISPLAY
f-label
WITH FRAME Dialog-Frame.
IF AVAILABLE tt-prop-script THEN
DISPLAY
tt-prop-script.dtm-code
tt-prop-script.class-dtm-code
tt-prop-script.language
tt-prop-script.script-name
tt-prop-script.revis_id
tt-prop-script.documentation
tt-prop-script.proc-type
tt-prop-script.script-type
tt-prop-script.script-value-type
tt-prop-script.signature
tt-prop-script.script-head
tt-prop-script.script-body
tt-prop-script.script-foot
cb-object-type
tt-prop-script.hidden_
WITH FRAME Dialog-Frame.
assign
tt-prop-script.script-head:read-only in frame Dialog-Frame = (p-mode = 'œ–Œ—ÃŒ“–':U)
tt-prop-script.script-body:read-only in frame Dialog-Frame = (p-mode = 'œ–Œ—ÃŒ“–':U)
tt-prop-script.script-foot:read-only in frame Dialog-Frame = (p-mode = 'œ–Œ—ÃŒ“–':U)
tt-prop-script.documentation:read-only in frame Dialog-Frame = (p-mode = 'œ–Œ—ÃŒ“–':U)
.
ENABLE
B-exit WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
b-quit
b-params WHEN p-mode <> 'ƒŒ¡¿¬À≈Õ»≈':U
B-Help
b-copy WHEN p-mode = 'ƒŒ¡¿¬À≈Õ»≈':U
tt-prop-script.dtm-code WHEN (p-mode = 'ƒŒ¡¿¬À≈Õ»≈':U AND p-dtm-code = ?)
tt-prop-script.class-dtm-code WHEN (p-mode <> 'œ–Œ—ÃŒ“–':U)
tt-prop-script.language WHEN p-mode = 'ƒŒ¡¿¬À≈Õ»≈':U
tt-prop-script.script-name
f-label
b-prop-map WHEN (p-mode <> 'œ–Œ—ÃŒ“–':U AND tt-prop-script.dtm-code > 0)
b-prop-map-2 WHEN (p-mode <> 'œ–Œ—ÃŒ“–':U AND tt-prop-script.dtm-code > 0)
tt-prop-script.documentation
tt-prop-script.proc-type   WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
tt-prop-script.script-type  WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
tt-prop-script.script-value-type WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
tt-prop-script.signature   WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
tt-prop-script.hidden   WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
tt-prop-script.script-head
tt-prop-script.script-body
tt-prop-script.script-foot
cb-object-type WHEN (p-mode = 'ƒŒ¡¿¬À≈Õ»≈':U
                     OR (p-mode = '»«Ã≈Õ≈Õ»≈':U
                         AND
                         cb-object-type <> '':U))
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
if p-mode = 'œ–Œ—ÃŒ“–':U then do:
  assign
  b-quit:label = "&¬˚ıÓ‰"
  b-quit:column = 1
  f-label:READ-ONLY IN FRAME Dialog-Frame = YES
  tt-prop-script.script-name:READ-ONLY IN FRAME Dialog-Frame = YES.
  hide b-exit in frame Dialog-Frame .
end.
if p-mode <> 'ƒŒ¡¿¬À≈Õ»≈':U then do:
  tt-prop-script.script-name:READ-ONLY IN FRAME Dialog-Frame = YES.
  hide b-copy in frame Dialog-Frame .
end.
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS recID  NO-UNDO.
IF p-mode = 'œ–Œ—ÃŒ“–':U THEN DO:
    RETURN.
END.
if p-mode = '»«Ã≈Õ≈Õ»≈':U then do:
  v-rec = p-rec.
end.
ASSIGN
FRAME Dialog-Frame
f-label
tt-prop-script.dtm-code
tt-prop-script.class-dtm-code
tt-prop-script.language
tt-prop-script.script-name
tt-prop-script.documentation
tt-prop-script.documentation
cb-object-type
tt-prop-script.proc-type
tt-prop-script.script-type
tt-prop-script.script-value-type
tt-prop-script.script-value-type = tt-prop-script.script-value-type + chr(44) + cb-object-type
tt-prop-script.script-head
tt-prop-script.script-body
tt-prop-script.script-foot
tt-prop-script.signature
tt-prop-script.HIDDEN_
.
run rul/prop-script1.p ( INPUT p-mode
                ,INPUT NO
                ,INPUT-OUTPUT v-rec
                ,INPUT tt-prop-script.dtm-code
                ,INPUT tt-prop-script.language
                ,INPUT tt-prop-script.script-name
                ,input tt-prop-script.revis_id
                ,input f-label
                ,input tt-prop-script.class-dtm-code
                ,INPUT tt-prop-script.documentation
                ,INPUT tt-prop-script.proc-type
                ,INPUT tt-prop-script.script-type
                ,INPUT tt-prop-script.script-value-type
                ,INPUT tt-prop-script.script-head
                ,INPUT tt-prop-script.script-body
                ,INPUT tt-prop-script.script-foot
                ,INPUT tt-prop-script.signature
                ,INPUT tt-prop-script.HIDDEN_
                ) no-error.
if error-status:error then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
p-rec = v-rec.
END PROCEDURE.
