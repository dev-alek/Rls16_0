DEFINE INPUT PARAMETER p-title-label AS CHARACTER NO-UNDO.
define input        parameter h-callback as handle    no-undo .
DEFINE INPUT PARAMETER p-mode AS INTEGER NO-UNDO.
define input parameter p-code as character no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-date-1 AS DATE NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-date-2 AS DATE NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-time-1 AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-time-2 AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-shift-num-1 AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-shift-num-2 AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-Z-count-1 AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-Z-count-2 AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-chk-num-1 AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-chk-num-2 AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-ok AS LOGICAL NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Диалог редактирования и показа параметров последнего принятого чека".
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
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE F-chk-num-1 LIKE chk-doc.chk-num
     LABEL "Номер чека"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE F-chk-num-2 LIKE chk-doc.chk-num
     LABEL "Номер чека"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-1 AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-2 AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE F-delim-11 AS CHARACTER FORMAT "X(256)":U INITIAL ":"
      VIEW-AS TEXT
     SIZE 1 BY .83 NO-UNDO.
DEFINE VARIABLE F-delim-12 AS CHARACTER FORMAT "X(256)":U INITIAL ":"
      VIEW-AS TEXT
     SIZE 1 BY .67 NO-UNDO.
DEFINE VARIABLE F-delim-21 AS CHARACTER FORMAT "X(256)":U INITIAL ":"
      VIEW-AS TEXT
     SIZE 1 BY .67 NO-UNDO.
DEFINE VARIABLE F-delim-22 AS CHARACTER FORMAT "X(256)":U INITIAL ":"
      VIEW-AS TEXT
     SIZE 1 BY .67 NO-UNDO.
DEFINE VARIABLE F-shift-num-1 LIKE chk-doc.shift-num
     LABEL "№ смены"
     VIEW-AS FILL-IN
     SIZE 4.5 BY 1 NO-UNDO.
DEFINE VARIABLE F-shift-num-2 LIKE chk-doc.shift-num
     LABEL "№ смены"
     VIEW-AS FILL-IN
     SIZE 4.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-z-count-1 AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
     LABEL "№ Z-отчета"
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-z-count-2 AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
     LABEL "№ Z-отчета"
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1 NO-UNDO.
DEFINE VARIABLE l-loc-hour-1 AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Время"
     VIEW-AS FILL-IN
     SIZE 3.25 BY 1 TOOLTIP "Стрелка вверх, вниз - изменение часа" NO-UNDO.
DEFINE VARIABLE l-loc-hour-2 AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Время"
     VIEW-AS FILL-IN
     SIZE 3.25 BY 1 TOOLTIP "Стрелка вверх, вниз - изменение часа" NO-UNDO.
DEFINE VARIABLE l-loc-min-1 AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3.25 BY 1 TOOLTIP "Стрелка вверх, вниз - изменение минут" NO-UNDO.
DEFINE VARIABLE l-loc-min-2 AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3.25 BY 1 TOOLTIP "Стрелка вверх, вниз - изменение минут" NO-UNDO.
DEFINE VARIABLE l-loc-sec-1 AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3.25 BY 1 TOOLTIP "Стрелка вверх, вниз - изменение секунд" NO-UNDO.
DEFINE VARIABLE l-loc-sec-2 AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3.25 BY 1 TOOLTIP "Стрелка вверх, вниз - изменение секунд" NO-UNDO.
DEFINE RECTANGLE RECT-from
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 47 BY 7.
DEFINE RECTANGLE RECT-to
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 47 BY 7.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     f-date-1 AT ROW 3 COL 6 COLON-ALIGNED
     l-loc-hour-1 AT ROW 3 COL 30.5 COLON-ALIGNED
     l-loc-min-1 AT ROW 3 COL 35.5 COLON-ALIGNED NO-LABEL
     l-loc-sec-1 AT ROW 3 COL 40.5 COLON-ALIGNED NO-LABEL
     f-date-2 AT ROW 3 COL 54 COLON-ALIGNED
     l-loc-hour-2 AT ROW 3 COL 78.5 COLON-ALIGNED
     l-loc-min-2 AT ROW 3 COL 83.5 COLON-ALIGNED NO-LABEL
     l-loc-sec-2 AT ROW 3 COL 88.5 COLON-ALIGNED NO-LABEL
     F-shift-num-1 AT ROW 4.5 COL 14 COLON-ALIGNED HELP
          ""
          LABEL "№ смены"
     F-shift-num-2 AT ROW 4.5 COL 62 COLON-ALIGNED HELP
          ""
          LABEL "№ смены"
     f-z-count-1 AT ROW 6 COL 14 COLON-ALIGNED
     f-z-count-2 AT ROW 6 COL 62 COLON-ALIGNED
     F-chk-num-1 AT ROW 7.5 COL 14 COLON-ALIGNED HELP
          ""
          LABEL "Номер чека" FORMAT "->>>>>>>>>>9"
     F-chk-num-2 AT ROW 7.5 COL 62 COLON-ALIGNED HELP
          ""
          LABEL "Номер чека" FORMAT "->>>>>>>>>>9"
     F-delim-11 AT ROW 3.17 COL 34 COLON-ALIGNED NO-LABEL
     F-delim-12 AT ROW 3.17 COL 39 COLON-ALIGNED NO-LABEL
     F-delim-21 AT ROW 3.17 COL 82 COLON-ALIGNED NO-LABEL
     F-delim-22 AT ROW 3.17 COL 87 COLON-ALIGNED NO-LABEL
     RECT-from AT ROW 2.25 COL 1
     RECT-to AT ROW 2.25 COL 48.5
     SPACE(0.49) SKIP(0.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры последнего чека"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CURSOR-DOWN OF l-loc-hour-1 IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-hour-1 .
  l-loc-hour-1 = l-loc-hour-1 -  1.
  if l-loc-hour-1 < 0 then return no-apply.
  display l-loc-hour-1 with frame Dialog-Frame.
END.
ON CURSOR-UP OF l-loc-hour-1 IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-hour-1 .
  l-loc-hour-1 = l-loc-hour-1 +  1.
  if l-loc-hour-1 > 24 then return no-apply.
  display l-loc-hour-1 with frame Dialog-Frame.
END.
ON LEAVE OF l-loc-hour-1 IN FRAME Dialog-Frame
DO:
    assign frame Dialog-Frame l-loc-hour-1 .
   if l-loc-hour-1 > 24 then do:
   message "Часы должны быть   до 24 ! " .
   return no-apply.
   end.
    if l-loc-hour-1 < 0 then do:
   message "Часы должны быть  от 0 до 24 ! " .
   return no-apply.
   end.
END.
ON CURSOR-DOWN OF l-loc-hour-2 IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-hour-2 .
  l-loc-hour-2 = l-loc-hour-2 -  1.
  if l-loc-hour-2 < 0 then return no-apply.
  display l-loc-hour-2 with frame Dialog-Frame.
END.
ON CURSOR-UP OF l-loc-hour-2 IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-hour-2 .
  l-loc-hour-2 = l-loc-hour-2 +  1.
  if l-loc-hour-2 > 24 then return no-apply.
  display l-loc-hour-2 with frame Dialog-Frame.
END.
ON LEAVE OF l-loc-hour-2 IN FRAME Dialog-Frame
DO:
    assign frame Dialog-Frame l-loc-hour-2 .
   if l-loc-hour-2 > 24 then do:
   message "Часы должны быть   до 24 ! " .
   return no-apply.
   end.
    if l-loc-hour-2 < 0 then do:
   message "Часы должны быть  от 0 до 24 ! " .
   return no-apply.
   end.
END.
ON CURSOR-DOWN OF l-loc-min-1 IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-min-1 .
  l-loc-min-1 = l-loc-min-1 -  1.
  if l-loc-min-1 < 0 then return no-apply.
  display l-loc-min-1 with frame Dialog-Frame.
END.
ON CURSOR-UP OF l-loc-min-1 IN FRAME Dialog-Frame
DO:
   assign  frame Dialog-Frame l-loc-min-1 .
  l-loc-min-1 = l-loc-min-1 +  1.
  if l-loc-min-1 > 59 then return no-apply.
  display l-loc-min-1 with frame Dialog-Frame.
END.
ON LEAVE OF l-loc-min-1 IN FRAME Dialog-Frame
DO:
   assign frame Dialog-Frame l-loc-min-1 .
   if l-loc-min-1 > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.
END.
ON CURSOR-DOWN OF l-loc-min-2 IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-min-2 .
  l-loc-min-2 = l-loc-min-2 -  1.
  if l-loc-min-2 < 0 then return no-apply.
  display l-loc-min-2 with frame Dialog-Frame.
END.
ON CURSOR-UP OF l-loc-min-2 IN FRAME Dialog-Frame
DO:
   assign  frame Dialog-Frame l-loc-min-2 .
  l-loc-min-2 = l-loc-min-2 +  1.
  if l-loc-min-2 > 59 then return no-apply.
  display l-loc-min-2 with frame Dialog-Frame.
END.
ON LEAVE OF l-loc-min-2 IN FRAME Dialog-Frame
DO:
   assign frame Dialog-Frame l-loc-min-2 .
   if l-loc-min-2 > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.
END.
ON CURSOR-DOWN OF l-loc-sec-1 IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-sec-1 .
  l-loc-sec-1 = l-loc-sec-1 -  1.
  if l-loc-sec-1 < 0 then return no-apply.
  display l-loc-sec-1 with frame Dialog-Frame.
END.
ON CURSOR-UP OF l-loc-sec-1 IN FRAME Dialog-Frame
DO:
   assign  frame Dialog-Frame l-loc-sec-1 .
  l-loc-sec-1 = l-loc-sec-1 +  1.
  if l-loc-sec-1 > 59 then return no-apply.
  display l-loc-sec-1 with frame Dialog-Frame.
END.
ON LEAVE OF l-loc-sec-1 IN FRAME Dialog-Frame
DO:
   assign frame Dialog-Frame l-loc-sec-1 .
   if l-loc-sec-1 > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.
END.
ON CURSOR-DOWN OF l-loc-sec-2 IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-sec-2 .
  l-loc-sec-2 = l-loc-sec-2 -  1.
  if l-loc-sec-2 < 0 then return no-apply.
  display l-loc-sec-2 with frame Dialog-Frame.
END.
ON CURSOR-UP OF l-loc-sec-2 IN FRAME Dialog-Frame
DO:
   assign  frame Dialog-Frame l-loc-sec-2 .
  l-loc-sec-2 = l-loc-sec-2 +  1.
  if l-loc-sec-2 > 59 then return no-apply.
  display l-loc-sec-2 with frame Dialog-Frame.
END.
ON LEAVE OF l-loc-sec-2 IN FRAME Dialog-Frame
DO:
   assign frame Dialog-Frame l-loc-sec-2 .
   if l-loc-sec-2 > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of f-date-1 in frame Dialog-Frame
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
on delete-character of f-date-1 in frame Dialog-Frame
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
on ctrl-d of f-date-1 in frame Dialog-Frame
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
on ctrl-b of f-date-1 in frame Dialog-Frame
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
on ctrl-e of f-date-1 in frame Dialog-Frame
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
on ctrl-f of f-date-1 in frame Dialog-Frame
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
  define MENU m-ed-date4
    MENU-ITEM m-ed-date4-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date4-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date4-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date4-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if f-date-1 :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      f-date-1 :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date4 :HANDLE
      f-date-1 :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle4 as handle no-undo .
  assign
    v-label-handle4 = f-date-1 :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle4)
  then do:
    if v-label-handle4 :tooltip = ""
    or v-label-handle4 :tooltip = ?
    then do:
      assign
        v-label-handle4 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date4-1 in menu m-ed-date4 DO:
    apply "ctrl-b":U to f-date-1 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-2 in menu m-ed-date4 DO:
    apply "ctrl-d":U to f-date-1 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-3 in menu m-ed-date4 DO:
    apply "ctrl-e":U to f-date-1 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-4 in menu m-ed-date4 DO:
    apply "ctrl-f":U to f-date-1 in frame Dialog-Frame .
  END.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of f-date-2 in frame Dialog-Frame
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
on delete-character of f-date-2 in frame Dialog-Frame
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
on ctrl-d of f-date-2 in frame Dialog-Frame
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
on ctrl-b of f-date-2 in frame Dialog-Frame
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
on ctrl-e of f-date-2 in frame Dialog-Frame
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
on ctrl-f of f-date-2 in frame Dialog-Frame
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
  define MENU m-ed-date6
    MENU-ITEM m-ed-date6-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date6-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date6-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date6-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if f-date-2 :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      f-date-2 :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date6 :HANDLE
      f-date-2 :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle6 as handle no-undo .
  assign
    v-label-handle6 = f-date-2 :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle6)
  then do:
    if v-label-handle6 :tooltip = ""
    or v-label-handle6 :tooltip = ?
    then do:
      assign
        v-label-handle6 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date6-1 in menu m-ed-date6 DO:
    apply "ctrl-b":U to f-date-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date6-2 in menu m-ed-date6 DO:
    apply "ctrl-d":U to f-date-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date6-3 in menu m-ed-date6 DO:
    apply "ctrl-e":U to f-date-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date6-4 in menu m-ed-date6 DO:
    apply "ctrl-f":U to f-date-2 in frame Dialog-Frame .
  END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN MYenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-date-1 l-loc-hour-1 l-loc-min-1 l-loc-sec-1 f-date-2 l-loc-hour-2
          l-loc-min-2 l-loc-sec-2 F-shift-num-1 F-shift-num-2 f-z-count-1
          f-z-count-2 F-chk-num-1 F-chk-num-2 F-delim-11 F-delim-12 F-delim-21
          F-delim-22
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help RECT-from RECT-to f-date-1 l-loc-hour-1
         l-loc-min-1 l-loc-sec-1 f-date-2 l-loc-hour-2 l-loc-min-2 l-loc-sec-2
         F-shift-num-1 F-shift-num-2 f-z-count-1 f-z-count-2 F-chk-num-1
         F-chk-num-2 F-delim-11 F-delim-12 F-delim-21 F-delim-22
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
ASSIGN
f-date-1 = p-date-1
f-date-2 = p-date-2
l-loc-hour-1  = integer(substring(string(p-time-1, "hh:mm:ss":U), 1, 2))
l-loc-min-1  = integer(substring(string(p-time-1, "hh:mm:ss":U), 4, 2))
l-loc-sec-1 = integer(substring(string(p-time-1, "hh:mm:ss":U), 7, 2))
l-loc-hour-2  = integer(substring(string(p-time-2, "hh:mm:ss":U), 1, 2))
l-loc-min-2  = integer(substring(string(p-time-2, "hh:mm:ss":U), 4, 2))
l-loc-sec-2 = integer(substring(string(p-time-2, "hh:mm:ss":U), 7, 2))
f-shift-num-1 = p-shift-num-1
f-shift-num-2 = p-shift-num-2
f-Z-count-1 = p-Z-count-1
f-Z-count-2 = p-Z-count-2
f-chk-num-1 = p-chk-num-1
f-chk-num-2 = p-chk-num-2
FRAME Dialog-Frame:TITLE = ENTRY(1, p-title-label, chr(4))
f-date-1:LABEL IN FRAME Dialog-Frame = (IF NUM-ENTRIES(p-title-label, chr(4)) > 1
                                         THEN ENTRY(2, p-title-label, chr(4))
                                         ELSE f-date-1:LABEL IN FRAME Dialog-Frame)
f-date-2:LABEL IN FRAME Dialog-Frame = (IF NUM-ENTRIES(p-title-label, chr(4)) > 2
                                        THEN ENTRY(3, p-title-label, chr(4))
                                        ELSE f-date-2:LABEL IN FRAME Dialog-Frame)
l-loc-hour-1:LABEL IN FRAME Dialog-Frame = (IF NUM-ENTRIES(p-title-label, chr(4)) > 3
                                            THEN ENTRY(4, p-title-label, chr(4))
                                            ELSE l-loc-hour-1:LABEL IN FRAME Dialog-Frame)
l-loc-hour-2:LABEL IN FRAME Dialog-Frame = (IF NUM-ENTRIES(p-title-label, chr(4)) > 4
                                            THEN ENTRY(5, p-title-label, chr(4))
                                            ELSE l-loc-hour-2:LABEL IN FRAME Dialog-Frame)
f-shift-num-1:LABEL IN FRAME Dialog-Frame = (IF NUM-ENTRIES(p-title-label, chr(4)) > 5
                                         THEN ENTRY(6, p-title-label, chr(4))
                                         ELSE f-shift-num-1:LABEL IN FRAME Dialog-Frame)
f-shift-num-2:LABEL IN FRAME Dialog-Frame = (IF NUM-ENTRIES(p-title-label, chr(4)) > 6
                                        THEN ENTRY(7, p-title-label, chr(4))
                                        ELSE f-shift-num-2:LABEL IN FRAME Dialog-Frame)
f-Z-count-1:LABEL IN FRAME Dialog-Frame = (IF NUM-ENTRIES(p-title-label, chr(4)) > 7
                                         THEN ENTRY(8, p-title-label, chr(4))
                                         ELSE f-z-count-1:LABEL IN FRAME Dialog-Frame)
f-Z-count-2:LABEL IN FRAME Dialog-Frame = (IF NUM-ENTRIES(p-title-label, chr(4)) > 8
                                        THEN ENTRY(9, p-title-label, chr(4))
                                        ELSE f-z-count-2:LABEL IN FRAME Dialog-Frame)
f-chk-num-1:LABEL IN FRAME Dialog-Frame = (IF NUM-ENTRIES(p-title-label, chr(4)) > 9
                                         THEN ENTRY(8, p-title-label, chr(4))
                                         ELSE f-chk-num-1:LABEL IN FRAME Dialog-Frame)
f-chk-num-2:LABEL IN FRAME Dialog-Frame = (IF NUM-ENTRIES(p-title-label, chr(4)) > 10
                                        THEN ENTRY(9, p-title-label, chr(4))
                                        ELSE f-chk-num-2:LABEL IN FRAME Dialog-Frame)
.
DISPLAY
f-date-1
l-loc-hour-1
l-loc-min-1
f-delim-11
f-shift-num-1
f-z-count-1
f-chk-num-1
WITH FRAME Dialog-Frame.
IF p-mode = 0 OR p-mode = 1 THEN DO:
    DISPLAY
    l-loc-sec-1
    f-delim-12
    WITH FRAME Dialog-Frame.
END.
IF p-mode = 0 OR p-mode = 2 THEN DO:
    DISPLAY
    f-date-2
    l-loc-hour-2
    l-loc-min-2
    f-delim-21
    f-shift-num-2
    f-z-count-2
    f-chk-num-2
    WITH FRAME Dialog-Frame.
END.
IF p-mode = 0 THEN DO:
    DISPLAY
    l-loc-sec-2
    f-delim-22
    WITH FRAME Dialog-Frame.
END.
IF p-mode = 2 OR p-mode = 3 THEN DO:
    HIDE
    l-loc-sec-1
    f-delim-12
    IN FRAME Dialog-Frame.
END.
IF p-mode = 1 OR p-mode = 3 THEN DO:
    HIDE
    f-date-2
    l-loc-hour-2
    l-loc-min-2
    f-delim-21
    f-shift-num-2
    f-z-count-2
    f-chk-num-2
    in FRAME Dialog-Frame.
END.
IF p-mode = 3 THEN DO:
    HIDE
    l-loc-sec-2
    f-delim-22
    IN FRAME Dialog-Frame.
END.
ENABLE
b-quit
B-exit
B-Help
f-date-1
l-loc-hour-1
l-loc-min-1
l-loc-sec-1 WHEN (p-mode = 0 OR p-mode = 1)
f-date-2 WHEN (p-mode = 0 OR p-mode = 2)
l-loc-hour-2 WHEN (p-mode = 0 OR p-mode = 2)
l-loc-min-2 WHEN (p-mode = 0 OR p-mode = 2)
l-loc-sec-2 WHEN p-mode = 0
f-shift-num-2 WHEN (p-mode = 0 OR p-mode = 2)
f-z-count-2 WHEN (p-mode = 0 OR p-mode = 2)
f-chk-num-2 WHEN (p-mode = 0 OR p-mode = 2)
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
if p-code = "report" then do:
    f-z-count-1:hidden = true .
    f-z-count-2:hidden = true .
    f-chk-num-1:hidden = true .
    f-chk-num-2:hidden = true .
end.
END PROCEDURE.
PROCEDURE proc-save :
define variable v-ok as logical no-undo .
define variable v-mes as character no-undo .
  ASSIGN
  f-date-1 FRAME Dialog-Frame
  l-loc-hour-1
  l-loc-min-1
  p-date-1 = f-date-1
  p-time-1 = l-loc-hour-1 * 3600 + l-loc-min-1 * 60 + l-loc-sec-1
  f-shift-num-1
  f-z-count-1
  f-chk-num-1
  p-z-count-1 = f-z-count-1
  p-shift-num-1 = f-shift-num-1
  p-chk-num-1 = f-chk-num-1
  .
  IF f-date-2:VISIBLE IN FRAME Dialog-Frame THEN DO:
    ASSIGN
    f-date-2
    l-loc-hour-2
    l-loc-min-2
    p-date-2 = f-date-2
    p-time-2 = l-loc-hour-2 * 3600 + l-loc-min-2 * 60 + l-loc-sec-2
    f-shift-num-2
    f-z-count-2
    f-chk-num-2
    p-z-count-2 = f-z-count-2
    p-shift-num-2 = f-shift-num-2
    p-chk-num-2 = f-chk-num-2
    .
  END.
  if  h-callback <> ?
  and valid-handle(h-callback)
  then do:
    if h-callback :get-signature("cb-d-time-validate") <> ""
    then do:
      define variable lok as logical no-undo .
      run cb-d-time-validate in h-callback
        (
          input p-date-1
         ,input p-date-2
         ,input p-time-1
         ,input p-time-2
         ,output v-ok
         ,output v-mes
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры проверки допустимости даты и времени" skip
          "файл" h-callback :file-name skip
          "процедура" "cb-d-time-validate" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return no-apply .
      end.
      if v-ok <> true then do:
        return no-apply .
      end.
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Программе был передан указатель на процедуру для проверки даты-времени" skip
        "В указанной процедуре отсутствует внутренняя процедура cb-d-time-validate " skip
        "файл" h-callback :file-name skip
        view-as alert-box error .
      return no-apply .
    end.
    if not v-ok then do:
      message
      v-mes
      view-as alert-box error .
      return no-apply.
    end.
    else do:
     p-ok = YES.
    end.
  end.
  p-ok = yes.
END PROCEDURE.
