define input  parameter p-title               as character no-undo .
define input  parameter p-text                as character no-undo .
define input  parameter p-delimiter           as character no-undo .
define input  parameter p-toggles             as character no-undo .
define input  parameter p-toggles-description as character no-undo .
define input  parameter p-toggles-init        as character no-undo .
define output parameter p-list                as character no-undo .
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Универсальный диалог для задания вопроса и наборов действий.".
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
define variable v-toggles    as integer no-undo.
define variable v-need-confirm as logical no-undo extent 9 .
define variable v-first-delimiter  as character no-undo init "|" .
define variable v-second-delimiter as character no-undo init "^" .
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
DEFINE VARIABLE description-1 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 61.75 BY 1.54 NO-UNDO.
DEFINE VARIABLE description-2 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 61.75 BY 1.54 NO-UNDO.
DEFINE VARIABLE description-3 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 61.75 BY 1.54 NO-UNDO.
DEFINE VARIABLE description-4 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 61.75 BY 1.54 NO-UNDO.
DEFINE VARIABLE description-5 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 61.75 BY 1.54 NO-UNDO.
DEFINE VARIABLE description-6 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 61.75 BY 1.54 NO-UNDO.
DEFINE VARIABLE description-7 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 61.75 BY 1.54 NO-UNDO.
DEFINE VARIABLE description-8 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 61.75 BY 1.54 NO-UNDO.
DEFINE VARIABLE description-9 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 61.75 BY 1.54 NO-UNDO.
DEFINE VARIABLE EDITOR-1 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 57.25 BY 2.75
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE T-1 AS LOGICAL INITIAL no
     LABEL "1"
     VIEW-AS TOGGLE-BOX
     SIZE 35.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-2 AS LOGICAL INITIAL no
     LABEL "2"
     VIEW-AS TOGGLE-BOX
     SIZE 35.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-3 AS LOGICAL INITIAL no
     LABEL "3"
     VIEW-AS TOGGLE-BOX
     SIZE 35.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-4 AS LOGICAL INITIAL no
     LABEL "4"
     VIEW-AS TOGGLE-BOX
     SIZE 35.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-5 AS LOGICAL INITIAL no
     LABEL "5"
     VIEW-AS TOGGLE-BOX
     SIZE 35.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-6 AS LOGICAL INITIAL no
     LABEL "6"
     VIEW-AS TOGGLE-BOX
     SIZE 35.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-7 AS LOGICAL INITIAL no
     LABEL "7"
     VIEW-AS TOGGLE-BOX
     SIZE 35.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-8 AS LOGICAL INITIAL no
     LABEL "8"
     VIEW-AS TOGGLE-BOX
     SIZE 35.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-9 AS LOGICAL INITIAL no
     LABEL "9"
     VIEW-AS TOGGLE-BOX
     SIZE 35.5 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     EDITOR-1 AT ROW 1 COL 22.5 NO-LABEL
     B-Help AT ROW 1 COL 81
     T-1 AT ROW 4 COL 1.5
     description-1 AT ROW 4 COL 37.25 NO-LABEL
     T-2 AT ROW 6 COL 1.5
     description-2 AT ROW 6 COL 37.25 NO-LABEL
     T-3 AT ROW 8 COL 1.5
     description-3 AT ROW 8 COL 37.25 NO-LABEL
     T-4 AT ROW 10 COL 1.5
     description-4 AT ROW 10 COL 37.25 NO-LABEL
     T-5 AT ROW 12 COL 1.5
     description-5 AT ROW 12 COL 37.25 NO-LABEL
     T-6 AT ROW 14 COL 1.5
     description-6 AT ROW 14 COL 37.25 NO-LABEL
     T-7 AT ROW 16 COL 1.5
     description-7 AT ROW 16 COL 37.25 NO-LABEL
     T-8 AT ROW 18 COL 1.5
     description-8 AT ROW 18 COL 37.25 NO-LABEL
     T-9 AT ROW 20 COL 1.5
     description-9 AT ROW 20 COL 37.25 NO-LABEL
     SPACE(0.24) SKIP(0.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       description-1:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       description-2:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-2:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       description-3:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-3:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       description-4:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-4:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       description-5:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-5:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       description-6:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-6:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       description-7:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-7:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       description-8:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-8:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       description-9:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-9:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       EDITOR-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       T-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       T-2:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       T-3:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       T-4:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       T-5:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       T-6:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       T-7:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       T-8:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       T-9:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  RETURN NO-APPLY .
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  ASSIGN
  t-1 WHEN t-1:visible
  t-2 WHEN t-2:visible
  t-3 WHEN t-3:visible
  t-4 WHEN t-4:visible
  t-5 WHEN t-5:visible
  t-6 WHEN t-6:visible
  t-7 WHEN t-7:visible
  t-8 WHEN t-8:visible
  t-9 WHEN t-9:visible
  .
  ASSIGN
  p-list = (IF t-1:VISIBLE THEN (STRING(t-1) + v-first-delimiter) ELSE "":U) +
           (IF t-1:VISIBLE THEN (STRING(t-2) + v-first-delimiter) ELSE "":U) +
           (IF t-1:VISIBLE THEN (STRING(t-3) + v-first-delimiter) ELSE "":U) +
           (IF t-1:VISIBLE THEN (STRING(t-4) + v-first-delimiter) ELSE "":U) +
           (IF t-1:VISIBLE THEN (STRING(t-5) + v-first-delimiter) ELSE "":U) +
           (IF t-1:VISIBLE THEN (STRING(t-6) + v-first-delimiter) ELSE "":U) +
           (IF t-1:VISIBLE THEN (STRING(t-7) + v-first-delimiter) ELSE "":U) +
           (IF t-1:VISIBLE THEN (STRING(t-8) + v-first-delimiter) ELSE "":U) +
           (IF t-1:VISIBLE THEN (STRING(t-9) + v-first-delimiter) ELSE "":U)
  p-list = right-trim(p-list, v-first-delimiter)
  .
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
on cursor-left anywhere do:
  apply "back-tab":u to focus .
end.
on cursor-right anywhere do:
  apply "tab":u to focus .
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY EDITOR-1 T-2
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit EDITOR-1 B-Help
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-bottom AS DECIMAL NO-UNDO.
do with frame Dialog-Frame:
  assign
    frame Dialog-Frame :title = p-title
  .
  v-bottom = editor-1:FRAME-ROW + editor-1:HEIGHT-CHARS.
  if length (p-delimiter) >= 1 then do:
    assign
      v-first-delimiter = substring(p-delimiter, 1, 1)
    .
  end.
  if length (p-delimiter) >= 2 then do:
    assign
      v-second-delimiter = substring(p-delimiter, 2, 1)
    .
  end.
  assign
    v-toggles = num-entries(p-toggles, v-first-delimiter)
    editor-1 = p-text
  .
  if v-toggles > 9 then do:
    message
      vss-workfile vss-revision vss-description skip
      "Количество флагов больше 9" skip
      "p-toggles" p-toggles skip
      view-as alert-box .
    undo, return error .
  end.
  if v-toggles <> num-entries(p-toggles-description, v-first-delimiter) then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Количество описаний флагов не совпадает с количеством флагов" skip
      "флагов" v-toggles skip
      "Описаний флагов" num-entries(p-toggles-description) skip
      view-as alert-box error .
    undo, return error .
  end.
  if v-toggles <> num-entries(p-toggles-init, v-first-delimiter) then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Количество начальных значений флагов не совпадает с количеством флагов" skip
      "флагов" v-toggles skip
      "Начальных значений флагов" num-entries(p-toggles-init) skip
      view-as alert-box error .
    undo, return error .
  end.
  define variable v-toggle-handle             as handle no-undo extent 9 .
  define variable v-toggle-description-handle as handle no-undo extent 9 .
  assign
    v-toggle-handle[1]             = t-1         :handle
    v-toggle-handle[2]             = t-2         :handle
    v-toggle-handle[3]             = t-3         :handle
    v-toggle-handle[4]             = t-4         :handle
    v-toggle-handle[5]             = t-5         :handle
    v-toggle-handle[6]             = t-6         :handle
    v-toggle-handle[7]             = t-7         :handle
    v-toggle-handle[8]             = t-8         :handle
    v-toggle-handle[9]             = t-9         :handle
    v-toggle-description-handle[1] = description-1 :handle
    v-toggle-description-handle[2] = description-2 :handle
    v-toggle-description-handle[3] = description-3 :handle
    v-toggle-description-handle[4] = description-4 :handle
    v-toggle-description-handle[5] = description-5 :handle
    v-toggle-description-handle[6] = description-6 :handle
    v-toggle-description-handle[7] = description-7 :handle
    v-toggle-description-handle[8] = description-8 :handle
    v-toggle-description-handle[9] = description-9 :handle
      .
  define variable v-handle             as handle no-undo .
  define variable v-handle-description as handle no-undo .
  define variable ind as integer no-undo .
  do ind = 1 to v-toggles
  :
    assign
      v-handle             = v-toggle-handle[ind]
      v-handle-description = v-toggle-description-handle[ind]
    .
    define variable v-toggle-text      as character no-undo .
    define variable v-description-text as character no-undo .
    define variable l-sensitive        as logical no-undo .
    define variable l-confirm          as logical no-undo .
    define variable v-btn-text-ind     as integer no-undo .
    assign
      v-toggle-text      = entry(ind, p-toggles, v-first-delimiter)
      v-description-text = entry(ind, p-toggles-description, v-first-delimiter)
      l-sensitive        = true
      l-confirm          = false
    .
    define variable v-toggle-attribute as character no-undo .
    do v-btn-text-ind = 2 to num-entries(v-toggle-text, v-second-delimiter )
    :
      assign
        v-toggle-attribute = entry(v-btn-text-ind, v-toggle-text, v-second-delimiter)
      .
      case v-toggle-attribute :
        when 'disable' then do:
          assign
            l-sensitive = false
          .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный атрибут флаг" skip
            "Атрибут" v-toggle-attribute skip
            "Описание флага" ind skip
            v-toggle-text skip
            view-as alert-box error .
        end.
      end case .
    end.
    if num-entries (v-toggle-text, v-second-delimiter ) >= 1 then do:
      assign
        v-toggle-text = entry(1, v-toggle-text, v-second-delimiter)
      .
    end.
    assign
      v-handle :label     = v-toggle-text
      v-handle :visible   = true
      v-handle :sensitive = l-sensitive
    .
    v-bottom = v-handle:frame-row + v-handle:HEIGHT-CHARS.
    v-handle:screen-value = entry(ind, p-toggles-init, v-first-delimiter).
    if v-description-text = "" then do:
      assign
        v-handle :width = min(max(v-handle :width
                                 ,length(v-toggle-text) + 2
                                 )
                             ,frame Dialog-Frame :width - v-handle :column - 1
                             )
       .
    end.
    if v-description-text <> "" then do:
      assign
        v-handle-description :visible      = true
        v-handle-description :sensitive    = true
        v-handle-description :read-only    = true
        v-handle-description :screen-value = v-description-text
      .
    end.
  end.
end.
ASSIGN
FRAME Dialog-Frame:HEIGHT-CHARS = v-bottom + 2
    .
DISPLAY
EDITOR-1
WITH FRAME Dialog-Frame.
ENABLE
B-exit
b-quit
EDITOR-1
B-Help
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
END PROCEDURE.
