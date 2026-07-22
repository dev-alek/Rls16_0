DEFINE BUFFER locked_wi-mode FOR ub.wi-mode.
DEFINE TEMP-TABLE tt-wi-mode NO-UNDO LIKE ub.wi-mode.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-mode-type AS character NO-UNDO.
DEFINE INPUT PARAMETER p-mode-id AS character NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма для ввода, просмотра и изменения режима работы".
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
define variable v-admin as logical no-undo .
DEFINE BUFFER buf_wi-mode FOR ub.wi-mode.
DEFINE BUTTON B-codex
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-prev-mode-id
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3.5 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE f-prev-mode-id-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 66 BY 1 NO-UNDO.
DEFINE VARIABLE f-ruleset-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 66 BY 1 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-wi-mode SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     tt-wi-mode.mode-type AT ROW 2.5 COL 14 COLON-ALIGNED WIDGET-ID 22
          LABEL "Тип режима" FORMAT "x(255)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Item 1","Item 1"
          DROP-DOWN-LIST
          SIZE 60 BY 1
     tt-wi-mode.mode-id AT ROW 4.5 COL 14 COLON-ALIGNED WIDGET-ID 4
          LABEL "ID режима"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-wi-mode.mode-name AT ROW 6.87 COL 31 COLON-ALIGNED WIDGET-ID 20
          LABEL "Название" FORMAT "x(40)"
          VIEW-AS FILL-IN NATIVE
          SIZE 66 BY 1
     f-prev-mode-id-name AT ROW 8.47 COL 31 COLON-ALIGNED NO-LABEL WIDGET-ID 24
     tt-wi-mode.prev-mode-id AT ROW 8.5 COL 13 COLON-ALIGNED WIDGET-ID 18
          LABEL "Пред. режим" FORMAT "x(12)"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     B-prev-mode-id AT ROW 8.5 COL 29 WIDGET-ID 16
     tt-wi-mode.codex_id AT ROW 10.33 COL 13.5 COLON-ALIGNED WIDGET-ID 50
          LABEL "Кодекс" FORMAT ">,>>>,>>9"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     B-codex AT ROW 10.33 COL 25.5 WIDGET-ID 28
     f-ruleset-name AT ROW 10.33 COL 31 COLON-ALIGNED NO-LABEL WIDGET-ID 54
     tt-wi-mode.ruleset_id AT ROW 11.43 COL 13.5 COLON-ALIGNED WIDGET-ID 52
          LABEL "Набор правил" FORMAT ">>>,>>>,>>9"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     tt-wi-mode.des AT ROW 14 COL 1 NO-LABEL WIDGET-ID 8
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 4
     SPACE(0.49) SKIP(0.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-codex IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-codex-id AS INTEGER NO-UNDO.
DEFINE BUFFER buf_ruleset FOR ub.ruleset.
IF tt-wi-mode.mode-type = ""
OR tt-wi-mode.mode-type =? THEN DO:
   MESSAGE "Не выбран тип режима"
   VIEW-AS ALERT-BOX ERROR.
   UNDO, RETURN NO-APPLY.
END.
if tt-wi-mode.codex_id <> 0 then do:
  find first buf_ruleset no-lock where
          buf_ruleset.codex_id = tt-wi-mode.codex_id
      and buf_ruleset.ruleset_id = tt-wi-mode.ruleset_id .
  v-rid-list = string(recid(buf_ruleset)).
end.
CASE tt-wi-mode.mode-type:
    WHEN 'cd-IBS-TH':U THEN DO:
        ASSIGN
        v-codex-id = 19.
    END.
    OTHERWISE DO:
        MESSAGE
        substitute("Неивестен кодекс для режима работы с типом &1", tt-wi-mode.mode-type)
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN NO-APPLY.
    END.
END CASE.
run rul/ruleset-s.w ( INPUT parparentproc
                     ,INPUT 'b-sel':U
                     ,input "codex"
                     ,input v-codex-id
                     ,INPUT-OUTPUT v-rid-list) NO-ERROR.
IF v-rid-list <> '':U THEN DO:
   FIND FIRST buf_ruleset NO-LOCK WHERE
            recid(buf_ruleset) = INTEGER(v-rid-list) NO-ERROR.
  IF NOT AVAILABLE buf_RULESET THEN RETURN NO-APPLY.
  ASSIGN
  tt-wi-mode.codex_id = buf_ruleset.codex_id
  tt-wi-mode.ruleset_id = buf_ruleset.ruleset_id
  f-ruleset-name = buf_ruleset.NAME
  .
  DISPLAY
  tt-wi-mode.CODEx_id
  tt-wi-mode.ruleset_id
  f-ruleset-name
  WITH FRAME Dialog-Frame.
END.
END.
ON CHOOSE OF B-prev-mode-id IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_wi-mode FOR ub.wi-mode.
  IF tt-wi-mode.prev-mode-id > '' THEN DO:
      FIND FIRST buf_wi-mode NO-LOCK WHERE
                buf_wi-mode.mode-type = tt-wi-mode.mode-type
          AND   buf_wi-mode.mode-id = tt-wi-mode.prev-mode-id NO-ERROR.
  END.
  run adm/wi-modes.w ( input parparentproc
                       ,INPUT "b-sel"
                       ,INPUT "mode-type"
                       ,INPUT tt-wi-mode.mode-type
                       ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  IF v-rid-list > '' THEN DO:
      FIND FIRST buf_wi-mode NO-LOCK WHERE
            RECID(buf_wi-mode) = INTEGER(v-rid-list) NO-ERROR.
      IF NOT AVAILABLE buf_wi-mode THEN DO:
         ASSIGN
         tt-wi-mode.prev-mode-id = ?
         f-prev-mode-id-name = ?
         .
      END.
      ELSE DO:
         ASSIGN
         tt-wi-mode.prev-mode-id = buf_wi-mode.mode-id
         f-prev-mode-id-name = buf_wi-mode.mode-name
         .
      END.
      DISPLAY
      tt-wi-mode.prev-mode-id
      f-prev-mode-id-name
      WITH FRAME Dialog-Frame.
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if lookup('admin', p-mode) > 0 then do:
    v-admin = yes.
    p-mode = trim(replace(p-mode, 'admin', ''), chr(44)).
  end.
  IF p-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
    CREATE tt-wi-mode.
    assign
    tt-wi-mode.mode-type = 'cd-IBS-TH':U.
  END.
  else do:
    IF p-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
      FIND FIRST LOCKED_wi-mode EXCLUSIVE-LOCK WHERE
                LOCKED_wi-mode.mode-id = p-mode-id
          AND LOCKED_wi-mode.mode-type = p-mode-type .
    END.
    IF p-mode = 'ПРОСМОТР':U THEN DO:
        FIND FIRST LOCKED_wi-mode no-LOCK WHERE
                  LOCKED_wi-mode.mode-id = p-mode-id
            AND LOCKED_wi-mode.mode-type = p-mode-type NO-ERROR.
    END.
    create tt-wi-mode.
    buffer-copy locked_wi-mode to tt-wi-mode.
  end.
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-prev-mode-id-name f-ruleset-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-wi-mode THEN
    DISPLAY tt-wi-mode.mode-type tt-wi-mode.mode-id tt-wi-mode.mode-name
          tt-wi-mode.prev-mode-id tt-wi-mode.codex_id tt-wi-mode.ruleset_id
          tt-wi-mode.des
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help tt-wi-mode.mode-id tt-wi-mode.mode-name
         f-prev-mode-id-name tt-wi-mode.prev-mode-id B-prev-mode-id B-codex
         tt-wi-mode.des
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE BUFFER buf_wi-mode FOR ub.wi-mode.
DEFINE BUFFER buf_ruleset FOR ub.ruleset.
IF tt-wi-mode.prev-mode-id > '' THEN DO:
  FIND FIRST buf_wi-mode NO-LOCK WHERE
            buf_wi-mode.mode-type = tt-wi-mode.mode-type
      AND   buf_wi-mode.mode-id = tt-wi-mode.prev-mode-id NO-ERROR.
  IF AVAILABLE buf_wi-mode THEN DO:
     f-prev-mode-id-name = buf_wi-mode.mode-name.
  END.
END.
if tt-wi-mode.codex_id <> 0 then do:
  find first buf_ruleset no-lock where
          buf_ruleset.codex_id = tt-wi-mode.codex_id
      and buf_ruleset.ruleset_id = tt-wi-mode.ruleset_id .
  IF AVAILABLE buf_ruleset THEN DO:
      ASSIGN
      f-ruleset-name = buf_ruleset.NAME.
  END.
end.
tt-wi-mode.MODE-TYPE:LIST-ITEM-PAIRS IN FRAME Dialog-Frame = 'Режимы работы кассы IBS TH POS':U + chr(44) + 'cd-IBS-TH':U.
IF AVAILABLE tt-wi-mode THEN
DISPLAY
tt-wi-mode.mode-type
tt-wi-mode.mode-id
tt-wi-mode.mode-name
tt-wi-mode.prev-mode-id
f-prev-mode-id-name
f-ruleset-name
tt-wi-mode.des
WITH FRAME Dialog-Frame .
ENABLE
B-exit  when p-mode <> 'ПРОСМОТР':U
b-quit
B-Help
tt-wi-mode.mode-type  when p-mode = 'ДОБАВЛЕНИЕ':U AND num-entries(tt-wi-mode.MODE-TYPE:list-item-pairs) > 2
tt-wi-mode.mode-id when p-mode = 'ДОБАВЛЕНИЕ':U
tt-wi-mode.mode-name       when p-mode <> 'ПРОСМОТР':U
b-prev-mode-id WHEN p-mode <> 'ПРОСМОТР':U
b-codex WHEN p-mode <> 'ПРОСМОТР':U
tt-wi-mode.des
WITH FRAME Dialog-Frame .
if p-mode = 'ПРОСМОТР':U then do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  tt-wi-mode.des:READ-ONLY IN FRAME Dialog-Frame = YES .
  hide b-exit in frame Dialog-Frame .
end.
VIEW FRAME Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS recID  NO-UNDO.
IF p-mode = 'ПРОСМОТР':U THEN DO:
    RETURN.
END.
IF p-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
  v-rec = p-rec.
END.
ASSIGN
FRAME Dialog-Frame
tt-wi-mode.mode-type
tt-wi-mode.mode-id
tt-wi-mode.mode-name
tt-wi-mode.prev-mode-id
tt-wi-mode.des.
run adm/wi-mode1.p ( INPUT p-mode
                ,INPUT NO
                ,INPUT-OUTPUT v-rec
                ,INPUT tt-wi-mode.mode-type
                ,INPUT tt-wi-mode.mode-id
                ,INPUT tt-wi-mode.prev-mode-id
                ,input tt-wi-mode.codex_id
                ,input tt-wi-mode.ruleset_id
                ,INPUT tt-wi-mode.mode-name
                ,INPUT tt-wi-mode.des
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
