DEFINE BUFFER locked_custom-labels FOR ub.custom-labels.
DEFINE TEMP-TABLE tt-custom-labels NO-UNDO LIKE ub.custom-labels.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-tbl-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-field-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-call-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-call-point AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-language AS CHARACTER NO-UNDO.
DEFINE input-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "—ÓÁ‰‡ÌËÂ ÔÓÎ¸ÁÓ‚‡ÚÂÎ¸ÒÍËı ÎÂÈ·ÎÓ‚".
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
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&¬‚Ó‰"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "œÓÏÓ&˘¸"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&ŒÚÏÂÌ‡"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     tt-custom-labels.call-point AT ROW 2.77 COL 13.5 COLON-ALIGNED WIDGET-ID 2
          LABEL "call-point" FORMAT "x(20)"
          VIEW-AS FILL-IN
          SIZE 26 BY 1
     tt-custom-labels.call-type AT ROW 2.77 COL 54.5 COLON-ALIGNED WIDGET-ID 4
          LABEL "call-type" FORMAT "x(20)"
          VIEW-AS FILL-IN
          SIZE 30 BY 1
     tt-custom-labels.tbl-name AT ROW 4 COL 13.5 COLON-ALIGNED WIDGET-ID 20
          LABEL "tbl-name"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN
          SIZE 31 BY 1
     tt-custom-labels.language AT ROW 4 COL 57.5 COLON-ALIGNED WIDGET-ID 14
          LABEL "language"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-custom-labels.fld-name AT ROW 5.27 COL 13.5 COLON-ALIGNED WIDGET-ID 22
          LABEL "fld-name"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN
          SIZE 31.5 BY 1
     tt-custom-labels.fld-data-type AT ROW 5.27 COL 62 COLON-ALIGNED WIDGET-ID 40
          LABEL "fld-data-type" FORMAT "x(10)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 30.5 BY 1
     tt-custom-labels.custom-label AT ROW 7 COL 13.5 COLON-ALIGNED WIDGET-ID 8
          LABEL "custom-label" FORMAT "x(40)"
          VIEW-AS FILL-IN
          SIZE 29.5 BY 1
     tt-custom-labels.custom-format AT ROW 7 COL 60.5 COLON-ALIGNED WIDGET-ID 6
          LABEL "custom-format" FORMAT "x(20)"
          VIEW-AS FILL-IN
          SIZE 27 BY 1
     tt-custom-labels.widget-width AT ROW 8.2 COL 60.5 COLON-ALIGNED WIDGET-ID 46 FORMAT "->>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-custom-labels.widget-type AT ROW 8.47 COL 13.5 COLON-ALIGNED NO-LABEL WIDGET-ID 42 FORMAT "x(12)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 29.5 BY 1
     tt-custom-labels.widget-list-items AT ROW 9.53 COL 16 NO-LABEL WIDGET-ID 48
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 76 BY 2.93
     tt-custom-labels.custom-view-func AT ROW 12.73 COL 17.5 COLON-ALIGNED WIDGET-ID 10
          LABEL "custom-view-func" FORMAT "x(32)"
          VIEW-AS FILL-IN
          SIZE 28 BY 1
     tt-custom-labels.reference-proc AT ROW 14.07 COL 18 COLON-ALIGNED WIDGET-ID 44 FORMAT "x(255)"
          VIEW-AS FILL-IN
          SIZE 54.5 BY 1
     tt-custom-labels.custom-tooltip AT ROW 15.17 COL 1.5 NO-LABEL WIDGET-ID 24
          VIEW-AS FILL-IN
          SIZE 98 BY 1
     tt-custom-labels.init-value-character AT ROW 16.43 COL 1 WIDGET-ID 26
          LABEL "Õ‡˜‡Î¸ÌÓÂ ÁÌ‡˜ÂÌËÂ (char)"
          VIEW-AS FILL-IN
          SIZE 45.5 BY 1
     tt-custom-labels.init-value-date AT ROW 17.93 COL 26 COLON-ALIGNED WIDGET-ID 28
          LABEL "Õ‡˜‡Î¸ÌÓÂ ÁÌ‡˜ÂÌËÂ (date)"
          VIEW-AS FILL-IN
          SIZE 18.5 BY 1
     tt-custom-labels.init-value-integer AT ROW 19.13 COL 29 COLON-ALIGNED WIDGET-ID 32
          LABEL "Õ‡˜‡Î¸ÌÓÂ ÁÌ‡˜ÂÌËÂ (integer)"
          VIEW-AS FILL-IN
          SIZE 23.5 BY 1
     tt-custom-labels.init-value-decimal AT ROW 20.57 COL 29 COLON-ALIGNED WIDGET-ID 30
          LABEL "Õ‡˜‡Î¸ÌÓÂ ÁÌ‡˜ÂÌËÂ (decimal)"
          VIEW-AS FILL-IN
          SIZE 37.5 BY 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
DEFINE FRAME Dialog-Frame
     tt-custom-labels.init-value-logical AT ROW 21.93 COL 31 WIDGET-ID 36
          LABEL "Õ‡˜‡Î¸ÌÓÂ ÁÌ‡˜ÂÌËÂ (logical)"
          VIEW-AS TOGGLE-BOX
          SIZE 40 BY 1
     "Listitems" VIEW-AS TEXT
          SIZE 12.5 BY 1 AT ROW 9.53 COL 2 WIDGET-ID 50
     SPACE(85.19) SKIP(12.69)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       tt-custom-labels.widget-list-items:RETURN-INSERTED IN FRAME Dialog-Frame  = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON VALUE-CHANGED OF tt-custom-labels.tbl-name IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE BUFFER buf_field FOR ub._field.
DEFINE BUFFER buf_file FOR ub._file.
ASSIGN
tt-custom-labels.tbl-name.
DO v-ii = 1 TO tt-custom-labels.fld-name:NUM-ITEMS IN FRAME Dialog-Frame:
  tt-custom-labels.fld-name:DELETE(tt-custom-labels.fld-name:ENTRY(v-ii)).
END.
FIND FIRST buf_file NO-LOCK WHERE
        buf_file._HIDDEN  = NO
     AND buf_file._file-name = tt-custom-labels.tbl-name NO-ERROR.
IF AVAILABLE buf_file THEN DO:
FOR EACH buf_field NO-LOCK WHERE
        buf_field._file-recid = RECID(buf_file):
  tt-custom-labels.fld-name:ADD-LAST( buf_field._field-name) IN FRAME Dialog-Frame.
END.
END.
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
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  IF p-mode = 'ƒŒ¡¿¬À≈Õ»≈':U THEN DO:
    CREATE tt-custom-labels.
  END.
  ELSE DO:
     IF p-mode = '»«Ã≈Õ≈Õ»≈':U THEN DO:
         FIND FIRST LOCKED_custom-labels EXCLUSIVE-LOCK WHERE
                   LOCKED_custom-labels.tbl-name = p-tbl-name
               AND LOCKED_custom-labels.fld-name = p-field-name
               AND LOCKED_custom-labels.call-type = p-call-type
               AND LOCKED_custom-labels.call-point = p-call-point
               AND LOCKED_custom-labels.language = p-language NO-ERROR.
     END.
     IF p-mode = 'œ–Œ—ÃŒ“–':U
     or p-mode = ' Œœ»–Œ¬¿Õ»≈':U
     THEN DO:
         FIND FIRST LOCKED_custom-labels no-LOCK WHERE
                   LOCKED_custom-labels.tbl-name = p-tbl-name
               AND LOCKED_custom-labels.fld-name = p-field-name
               AND LOCKED_custom-labels.call-type = p-call-type
               AND LOCKED_custom-labels.call-point = p-call-point
               AND LOCKED_custom-labels.language = p-language NO-ERROR.
     END.
     IF NOT AVAILABLE LOCKED_custom-labels THEN DO:
         MESSAGE
         "ÕÂ Ì‡È‰ÂÌ‡ Á‡ÔËÒ¸"
         VIEW-AS ALERT-BOX ERROR.
       return error.
     END.
     CREATE tt-custom-labels.
     BUFFER-COPY LOCKED_custom-labels TO tt-custom-labels.
     if p-mode = ' Œœ»–Œ¬¿Õ»≈':U then do:
       assign
       v-is-copy = yes
       p-mode = 'ƒŒ¡¿¬À≈Õ»≈':U.
     end.
  END.
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  IF AVAILABLE tt-custom-labels THEN
    DISPLAY tt-custom-labels.call-point tt-custom-labels.call-type
          tt-custom-labels.tbl-name tt-custom-labels.language
          tt-custom-labels.fld-name tt-custom-labels.fld-data-type
          tt-custom-labels.custom-label tt-custom-labels.custom-format
          tt-custom-labels.widget-width tt-custom-labels.widget-type
          tt-custom-labels.widget-list-items tt-custom-labels.custom-view-func
          tt-custom-labels.reference-proc tt-custom-labels.custom-tooltip
          tt-custom-labels.init-value-character tt-custom-labels.init-value-date
          tt-custom-labels.init-value-integer
          tt-custom-labels.init-value-decimal
          tt-custom-labels.init-value-logical
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help tt-custom-labels.call-point
         tt-custom-labels.call-type tt-custom-labels.tbl-name
         tt-custom-labels.language tt-custom-labels.fld-name
         tt-custom-labels.fld-data-type tt-custom-labels.custom-label
         tt-custom-labels.custom-format tt-custom-labels.widget-width
         tt-custom-labels.widget-type tt-custom-labels.widget-list-items
         tt-custom-labels.custom-view-func tt-custom-labels.reference-proc
         tt-custom-labels.custom-tooltip tt-custom-labels.init-value-character
         tt-custom-labels.init-value-date tt-custom-labels.init-value-integer
         tt-custom-labels.init-value-decimal
         tt-custom-labels.init-value-logical
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE BUFFER buf_file FOR _file.
FOR EACH buf_file NO-LOCK WHERE
        buf_file._HIDDEN  = NO:
  tt-custom-labels.tbl-name:ADD-LAST( buf_file._file-name) IN FRAME Dialog-Frame.
END.
tt-custom-labels.fld-data-type:LIST-ITEMS IN FRAME Dialog-Frame = 'character,date,decimal,integer,logical':U.
tt-custom-labels.widget-type:LIST-ITEMS IN FRAME Dialog-Frame = "fill-in,toggle-box,combo-box".
IF AVAILABLE tt-custom-labels THEN
DISPLAY
tt-custom-labels.call-type
tt-custom-labels.call-point
tt-custom-labels.custom-format
tt-custom-labels.custom-label
tt-custom-labels.custom-view-func
tt-custom-labels.reference-proc
tt-custom-labels.language
tt-custom-labels.tbl-name
tt-custom-labels.fld-name
tt-custom-labels.fld-data-type
tt-custom-labels.custom-tooltip
tt-custom-labels.init-value-character
tt-custom-labels.init-value-date
tt-custom-labels.init-value-decimal
tt-custom-labels.init-value-integer
tt-custom-labels.init-value-logical
tt-custom-labels.widget-type
tt-custom-labels.widget-width
WITH FRAME Dialog-Frame.
tt-custom-labels.widget-list-items:screen-value = tt-custom-labels.widget-list-items.
ENABLE
B-exit WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
b-quit
B-Help
tt-custom-labels.call-type WHEN p-mode = 'ƒŒ¡¿¬À≈Õ»≈':U
tt-custom-labels.call-point WHEN p-mode = 'ƒŒ¡¿¬À≈Õ»≈':U
tt-custom-labels.custom-format WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
tt-custom-labels.custom-label WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
tt-custom-labels.custom-view-func WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
tt-custom-labels.reference-proc WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
tt-custom-labels.language WHEN p-mode = 'ƒŒ¡¿¬À≈Õ»≈':U
tt-custom-labels.tbl-name WHEN p-mode = 'ƒŒ¡¿¬À≈Õ»≈':U
tt-custom-labels.fld-name WHEN p-mode = 'ƒŒ¡¿¬À≈Õ»≈':U
tt-custom-labels.custom-tooltip WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
tt-custom-labels.init-value-character WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
tt-custom-labels.init-value-date WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
tt-custom-labels.init-value-decimal WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
tt-custom-labels.init-value-integer WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
tt-custom-labels.init-value-logical WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
tt-custom-labels.fld-data-type WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
tt-custom-labels.widget-type WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
tt-custom-labels.widget-width WHEN p-mode <> 'œ–Œ—ÃŒ“–':U
tt-custom-labels.widget-list-items
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
IF p-mode = 'œ–Œ—ÃŒ“–':U THEN DO:
   HIDE
   b-exit IN FRAME Dialog-Frame.
   ASSIGN
   b-quit:LABEL = "&¬˚ıÓ‰"
   b-quit:COLUMN = 1
   tt-custom-labels.widget-list-items:read-only = yes
   .
END.
APPLY "value-changed" TO tt-custom-labels.tbl-name.
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
IF p-mode = 'œ–Œ—ÃŒ“–':U THEN RETURN ERROR.
ASSIGN
FRAME Dialog-Frame
tt-custom-labels.call-type
tt-custom-labels.call-point
tt-custom-labels.custom-format
tt-custom-labels.custom-label
tt-custom-labels.custom-view-func
tt-custom-labels.language
tt-custom-labels.tbl-name
tt-custom-labels.fld-name
tt-custom-labels.fld-data-type
tt-custom-labels.custom-tooltip
tt-custom-labels.init-value-character
tt-custom-labels.init-value-date
tt-custom-labels.init-value-decimal
tt-custom-labels.init-value-integer
tt-custom-labels.init-value-logical
tt-custom-labels.reference-proc
tt-custom-labels.widget-type
tt-custom-labels.widget-width
.
IF p-mode = '»«Ã≈Õ≈Õ»≈':U THEN DO:
  v-rec = p-rec.
END.
if tt-custom-labels.tbl-name = ? then do:
  tt-custom-labels.tbl-name = '':U.
end.
if tt-custom-labels.fld-name = ? then do:
  tt-custom-labels.fld-name = '':U.
end.
run utl/cuslabl1.p ( INPUT p-mode
                    ,INPUT NO
                     ,INPUT-OUTPUT v-rec
                     ,INPUT tt-custom-labels.tbl-name
                     ,INPUT tt-custom-labels.fld-name
                     ,INPUT tt-custom-labels.call-type
                     ,INPUT tt-custom-labels.call-point
                     ,INPUT tt-custom-labels.LANGUAGE
                     ,INPUT tt-custom-labels.fld-data-type
                     ,INPUT tt-custom-labels.custom-label
                     ,INPUT tt-custom-labels.custom-view-func
                     ,INPUT tt-custom-labels.reference-proc
                     ,INPUT tt-custom-labels.custom-format
                     ,INPUT tt-custom-labels.custom-tooltip
                      ,INPUT tt-custom-labels.init-value-character
                      ,INPUT tt-custom-labels.init-value-date
                      ,INPUT tt-custom-labels.init-value-decimal
                      ,INPUT tt-custom-labels.init-value-integer
                      ,INPUT tt-custom-labels.init-value-logical
                      ,INPUT tt-custom-labels.widget-type
                      ,INPUT tt-custom-labels.widget-width
                     ,INPUT tt-custom-labels.widget-LIST-ITEMS:SCREEN-VALUE
                     ) NO-ERROR.
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
