DEFINE NEW SHARED BUFFER down-rule FOR ub.rule.
DEFINE BUFFER locked_rule FOR ub.rule.
DEFINE BUFFER locked_ruledict FOR ub.ruledict.
DEFINE NEW SHARED TEMP-TABLE tt-rule NO-UNDO LIKE ub.rule
       field level as integer.
DEFINE NEW SHARED TEMP-TABLE tt-rule-i-script NO-UNDO LIKE ub.rule-i-script.
DEFINE NEW SHARED TEMP-TABLE tt-rule-script NO-UNDO LIKE ub.rule-script
       field level as integer
       field gen-order as character
       field upper_rule_id as integer.
DEFINE NEW SHARED TEMP-TABLE tt-ruledict-param NO-UNDO LIKE ub.ruledict-param.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-rule-id AS INTEGER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование одного правила RUM".
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
DEFINE VARIABLE v-level AS INTEGER NO-UNDO.
define variable v-mess as character no-undo .
define variable v-ok as logical no-undo .
DEFINE BUFFER FIRST_rule FOR ub.RULE.
DEFINE VARIABLE add-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE move-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-param-num-list AS CHARACTER NO-UNDO.
define variable v-is-admin-mode as logical no-undo .
DEFINE BUFFER MOVE_tt-rule-script FOR tt-rule-script.
DEFINE MENU MENU-B-add
       MENU-ITEM m_cond0        LABEL "Условие"
       MENU-ITEM m_cons0        LABEL "Следствие"
       MENU-ITEM m_goto0        LABEL "Переход"
       MENU-ITEM m_cycle-cond0  LABEL "Цикл-Условие"
       MENU-ITEM m_rule         LABEL "Подправило"
       MENU-ITEM m_else-rule    LABEL "Иначе-Подправило"
       MENU-ITEM m_cond         LABEL "Условие в подправило"
       MENU-ITEM m_cons         LABEL "Следствие в подправило"
       MENU-ITEM m_goto         LABEL "Переход в подправило"
       MENU-ITEM m_cycle-cond   LABEL "Цикл-Условие"  .
DEFINE MENU MENU-b-sel
       MENU-ITEM m_script0      LABEL "Скрипт в правило"
       MENU-ITEM m_script       LABEL "Скрипт в подправило".
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-codex
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-image
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 2.5 BY 1.
DEFINE BUTTON b-move
     LABEL "Перенести"
     SIZE 10 BY 1.
DEFINE BUTTON b-params
     LABEL "Параметры"
     SIZE 10 BY 1.
DEFINE BUTTON b-print
     LABEL "Button 1"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sel
     LABEL "Выбор"
     SIZE 10 BY 1.
DEFINE BUTTON B-text
     LABEL "Изм.текст"
     SIZE 10 BY 1.
DEFINE VARIABLE RS-language AS CHARACTER INITIAL "ABL"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "ABL", "ABL",
"lan", "lan"
     SIZE 14.5 BY .77 NO-UNDO.
DEFINE VARIABLE T-hidden AS LOGICAL INITIAL no
     LABEL "Скрытое содержание"
     VIEW-AS TOGGLE-BOX
     SIZE 22 BY .8 NO-UNDO.
DEFINE QUERY br-rule-script FOR
      tt-rule-script SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      tt-rule SCROLLING.
DEFINE BROWSE br-rule-script
  QUERY br-rule-script NO-LOCK DISPLAY
      tt-rule-script.rule_id    COLUMN-LABEL "Код!подправила" FORMAT ">>>>>>>>9"
tt-rule-script.gen-order  COLUMN-LABEL "ПОР" FORMAT "X(255)" WIDTH 12
tt-rule-script.level    COLUMN-LABEL "Уро!вень" FORMAT ">9"
tt-rule-script.upper_rule_id  COLUMN-LABEL "Вышест.!Правило" FORMAT ">>>>>>>>9"
tt-rule-script.script-type COLUMN-LABEL "Тип" FORMAT "X(4)" WIDTH 4
tt-rule-script.script_id COLUMN-LABEL "Код!скрипта" FORMAT ">>>>>>>>9" WIDTH 4
tt-rule-script.salience  COLUMN-LABEL "Пор." FORMAT ">>9"
(fill(chr(32), tt-rule-script.level * 2)  + tt-rule-script.script)
COLUMN-LABEL "Выражение" FORMAT "X(255)" WIDTH 60
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 14.5
         FONT 4 ROW-HEIGHT-CHARS .54 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     tt-rule.rule_id AT ROW 1 COL 33.5 COLON-ALIGNED WIDGET-ID 2
          LABEL "Код правила" FORMAT ">>>>>>>9"
          VIEW-AS FILL-IN NATIVE
          SIZE 10 BY 1
          FGCOLOR 4
     T-hidden AT ROW 1 COL 48.5 WIDGET-ID 46
     b-print AT ROW 1 COL 92 WIDGET-ID 44
     B-Help AT ROW 1 COL 95
     tt-rule.codex_id AT ROW 2 COL 33.5 COLON-ALIGNED WIDGET-ID 4
          LABEL "Кодекс" FORMAT ">>>>>>9"
          VIEW-AS FILL-IN NATIVE
          SIZE 10 BY 1
          FGCOLOR 4
     tt-rule.reusable-params AT ROW 2 COL 69.5 COLON-ALIGNED WIDGET-ID 40
          LABEL "Повторно используемо"
          VIEW-AS FILL-IN NATIVE
          SIZE 27.5 BY 1
     B-codex AT ROW 2.07 COL 46 WIDGET-ID 28
     tt-rule.name AT ROW 3 COL 1 NO-LABEL WIDGET-ID 32
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 1.87
     tt-rule.image-file-name AT ROW 5 COL 41.5 COLON-ALIGNED WIDGET-ID 48
          LABEL "Файл изображ." FORMAT "x(24)"
          VIEW-AS FILL-IN NATIVE
          SIZE 40 BY 1
     b-image AT ROW 5 COL 96 WIDGET-ID 50
     tt-rule.documentation AT ROW 6 COL 1 NO-LABEL WIDGET-ID 8
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 1.8
     b-sel AT ROW 7.77 COL 25 WIDGET-ID 38
     B-add AT ROW 7.77 COL 35 WIDGET-ID 18
     B-del AT ROW 7.77 COL 45 WIDGET-ID 20
     B-chg AT ROW 7.77 COL 55 WIDGET-ID 22
     b-move AT ROW 7.77 COL 65 WIDGET-ID 36
     B-text AT ROW 7.77 COL 75 WIDGET-ID 42
     b-params AT ROW 7.77 COL 85 WIDGET-ID 30
     RS-language AT ROW 8 COL 1 NO-LABEL WIDGET-ID 14
     br-rule-script AT ROW 8.77 COL 1 WIDGET-ID 100
     "Описание" VIEW-AS TEXT
          SIZE 13.5 BY .77 AT ROW 5 COL 1 WIDGET-ID 10
     "Название" VIEW-AS TEXT
          SIZE 13.5 BY .77 AT ROW 2 COL 1 WIDGET-ID 34
     SPACE(84.50) SKIP(20.50)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Правило"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add:HANDLE.
ASSIGN
       b-sel:HIDDEN IN FRAME Dialog-Frame           = TRUE
       b-sel:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-sel:HANDLE.
ASSIGN
       br-rule-script:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.
ON END-ERROR OF FRAME Dialog-Frame
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  DEFINE BUFFER buf_tt-rule-script FOR tt-rule-script.
  IF p-mode = 'ДОБАВЛЕНИЕ':U THEN do:
    FIND FIRST buf_tt-rule-script NO-LOCK WHERE
                buf_tt-rule-script.RULE_id = tt-rule.RULE_id NO-ERROR.
    IF AVAILABLE buf_tt-rule-script THEN DO:
      MESSAGE
      "Выйти из режима редактирования и не сохранять правило"
      VIEW-AS ALERT-BOX ERROR BUTTONS YES-NO UPDATE glog.
      IF NOT glog  THEN DO:
         RETURN NO-APPLY.
      END.
    END.
  END.
END.
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
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
 IF add-option = '':U  THEN DO:
    run gbl/pop-up.p ( INPUT self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if add-option = "":U then do:
      return no-apply.
  end.
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option
                                    ,INPUT '':U
                                    ,INPUT '':U
                                    ,input 0
                                    ,input 0
                                    ,input 0
                                    ) NO-ERROR.
  IF error-status:ERROR THEN DO:
      add-option = '':u.
      RETURN NO-APPLY.
  END.
  add-option = '':u.
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
  if not available tt-rule-script then return no-apply.
  IF tt-rule.codex_id = 0  THEN DO:
     MESSAGE
     "Для редактирования необходима сначала выбрать кодекс правил"
      VIEW-AS ALERT-BOX ERROR.
     RETURN NO-APPLY.
  END.
  run rul/updrule.w (
                      INPUT parparentproc
                     ,input 'ИЗМЕНЕНИЕ':U
                     ,INPUT tt-rule.codex_id
                     ,input tt-rule.root_rule_id
                     ,input tt-rule.upper_rule_id
                     ,input tt-rule-script.rule_id
                     ,input tt-rule-script.script-type
                     ,input tt-rule-script.salience
                     ,input-output tt-rule-script.script_id
                     ) no-error.
  if error-status:error then do:
    return no-apply.
  end.
  br-rule-script:refresh().
END.
ON CHOOSE OF B-codex IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_ruleset FOR ub.ruleset.
if tt-rule.codex_id <> 0 then do:
  find first buf_ruleset no-lock where
          buf_ruleset.codex_id = tt-rule.codex_id
      and buf_ruleset.ruleset_id = 0 .
  v-rid-list = string(recid(buf_ruleset)).
end.
run rul/ruleset-s.w ( INPUT parparentproc
                     ,INPUT 'b-sel':U
                     ,input "only-codex"
                     ,input 0
                     ,INPUT-OUTPUT v-rid-list) NO-ERROR.
IF v-rid-list <> '':U THEN DO:
   FIND FIRST buf_ruleset NO-LOCK WHERE
            recid(buf_ruleset) = INTEGER(v-rid-list) NO-ERROR.
  IF NOT AVAILABLE buf_RULESET THEN RETURN NO-APPLY.
  ASSIGN
  tt-rule.codex_id = buf_ruleset.codex_id.
  DISPLAY
  tt-rule.CODEx_id
  WITH FRAME Dialog-Frame.
END.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
 DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  IF NOT AVAILABLE tt-rule-script THEN RETURN NO-APPLY.
  MESSAGE
  substitute("Вы уверены, что хотите удалить данный скрипт&1"  +
             "&2&1" +
             "код подправила &3, уровень &4 тип скрипта &5 код скрипта &6 порядок &7"
             , chr(10)
             ,tt-rule-script.script
             ,tt-rule-script.rule_id
             ,tt-rule-script.level
             ,tt-rule-script.script-type
             ,tt-rule-script.script_id
             ,tt-rule-script.salience  )
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO  UPDATE glog.
  IF not glog THEN RETURN NO-APPLY.
  RUN proc-b-del IN THIS-PROCEDURE ( input tt-rule-script.rule_id
                                    ,input tt-rule-script.script_id) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-image IN FRAME Dialog-Frame
DO:
 define variable v_os-file   AS CHAR NO-UNDO INIT "".
define variable ll_commit AS LOG    NO-UNDO INIT NO.
define variable file-name        as character no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable glog as logical no-undo .
  SYSTEM-DIALOG GET-FILE v_os-file
  TITLE "Задайте файла изображения"
  FILTERS
    " Все bmp файлы (*.bmp) " "*.bmp",
    " Все ico файлы (*.ico) " "*.ico",
    " Все gif файлы (*.gif) " "*.gif",
    " Все jpg файлы (*.jpg) " "*.jpg",
    " Все файлы (*.*) "                      "*.*"
  INITIAL-FILTER 1
  DEFAULT-EXTENSION ".xml"
  USE-FILENAME
  MUST-EXIST
  UPDATE ll_commit
  .
  IF ll_commit <> YES THEN do:
      RETURN NO-APPLY.
  end.
  IF v_os-file = PROGRAM-NAME( 1 ) THEN DO:
      BELL.
      MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.
  END.
  ASSIGN file-name = ( IF SEARCH( v_os-file ) = ? THEN v_os-file ELSE SEARCH( v_os-file ) ).
  run gbl/filename.p (
                  input  v_os-file
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
  if error-status:error  = ? then do:
    return no-apply.
  end.
  assign
  file-name = v-full-path.
  DISPlay
  file-name @ tt-rule.image-file-name WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF b-move IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE tt-rule-script THEN DO:
      RETURN NO-APPLY.
  END.
  RUN proc-b-move IN THIS-PROCEDURE ( input tt-rule-script.rule_id
                                    ,input tt-rule-script.script_id) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF b-params IN FRAME Dialog-Frame
DO:
  RUN proc-b-params IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      UNDO, RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF b-print IN FRAME Dialog-Frame
DO:
  RUN proc-b-print IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-sel IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  DEFINE VARIABLE v-cont AS LOGICAL NO-UNDO.
  IF NOT AVAILABLE tt-rule-script THEN DO:
  END.
  IF RECID(tt-rule-script) = recid(move_tt-rule-script) THEN DO:
     MESSAGE
     "Используйте стрелки"
     VIEW-AS ALERT-BOX.
  END.
  ELSE DO:
   IF move-option = '':U THEN DO:
      run gbl/pop-up.p ( INPUT b-sel:handle, input no ) no-error.
      IF ERROR-STATUS:ERROR
      OR move-option = '':U THEN DO:
      END.
      ELSE DO:
         v-cont = YES.
      END.
   END.
   else do:
     v-cont = yes.
   end.
   IF v-cont = YES THEN
      MESSAGE
      substitute("Вы уверены, что хотите перенести скрипт&1"  +
                 "&2&1" +
                 "код подправила &3, уровень &4 тип скрипта &5 код скрипта &6 порядок &7&1"
                 , chr(10)
                 ,move_tt-rule-script.script
                 ,move_tt-rule-script.rule_id
                 ,move_tt-rule-script.level
                 ,move_tt-rule-script.script-type
                 ,move_tt-rule-script.script_id
                 ,move_tt-rule-script.salience  )
      SUBSTITUTE("после скрипта&1" +
                 "&2&1" +
                 "код подправила &3, уровень &4 тип скрипта &5 код скрипта &6 порядок &7"
                 , chr(10)
                 ,tt-rule-script.script
                 ,tt-rule-script.rule_id
                 ,tt-rule-script.level
                 ,tt-rule-script.script-type
                 ,tt-rule-script.script_id
                 ,tt-rule-script.salience  )
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO  UPDATE glog.
      IF not glog THEN do:
        v-cont = NO.
      END.
  END.
  IF v-cont = YES then DO:
    RUN proc-aff-move IN THIS-PROCEDURE ( input move_tt-rule-script.rule_id
                                             ,input move_tt-rule-script.script_id
                                             ,INPUT tt-rule-script.RULE_id
                                             ,INPUT tt-rule-script.script_id
                                             ,INPUT move-option) NO-ERROR.
  END.
  RUN proc-cancel-move IN THIS-PROCEDURE.
END.
ON CHOOSE OF B-text IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-longchar AS LONGCHAR NO-UNDO.
  DEFINE VARIABLE v-ok AS LOGical NO-UNDO.
  if not available tt-rule-script then return no-apply.
  v-longchar = tt-rule-script.script.
     run gbl/d-longchar.w (
                           INPUT ?
                          ,INPUT (if v-is-admin-mode then 'readonly=no\' else '')
                          ,input-output v-longchar
                          ,output v-ok
                           ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   OR NOT v-ok THEN undo, RETURN NO-apply.
   ASSIGN
   tt-rule-script.script = v-longchar.
   br-rule-script:REFRESH().
   v-longchar = '':U.
END.
ON VALUE-CHANGED OF br-rule-script IN FRAME Dialog-Frame
DO:
  RUN switch-rule IN THIS-PROCEDURE.
END.
ON CHOOSE OF MENU-ITEM m_cond
DO:
  ASSIGN
  add-option = 'COND':U.
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option
                                    ,INPUT '':U
                                    ,INPUT '':U
                                    ,input 0
                                    ,input 0
                                    ,input 0
                                    ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     ASSIGN
     add-option = '':U.
     RETURN NO-APPLY.
  END.
  ASSIGN
  add-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_cond0
DO:
   ASSIGN
  add-option = ('COND':U + chr(44) + "0").
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option
                                    ,INPUT '':U
                                    ,INPUT '':U
                                    ,input 0
                                    ,input 0
                                    ,input 0
                                    ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     ASSIGN
     add-option = '':U.
     RETURN NO-APPLY.
  END.
  ASSIGN
  add-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_cons
DO:
    ASSIGN
  add-option = 'CONS':U.
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option
                                    ,INPUT '':U
                                    ,INPUT '':U
                                    ,input 0
                                    ,input 0
                                    ,input 0
                                    ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     ASSIGN
     add-option = '':U.
     RETURN NO-APPLY.
  END.
  ASSIGN
  add-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_cons0
DO:
    ASSIGN
  add-option = ('CONS':U + chr(44) + "0").
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option
                                    ,INPUT '':U
                                    ,INPUT '':U
                                    ,input 0
                                    ,input 0
                                    ,input 0
                                    ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     ASSIGN
     add-option = '':U.
     RETURN NO-APPLY.
  END.
  ASSIGN
  add-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_cycle-cond
DO:
  ASSIGN
  add-option = 'CYCLE-COND':U.
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option
                                    ,INPUT '':U
                                    ,INPUT '':U
                                    ,input 0
                                    ,input 0
                                    ,input 0
                                    ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     ASSIGN
     add-option = '':U.
     RETURN NO-APPLY.
  END.
  ASSIGN
  add-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_cycle-cond0
DO:
   ASSIGN
  add-option = ('CYCLE-COND':U + chr(44) + "0").
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option
                                    ,INPUT '':U
                                    ,INPUT '':U
                                    ,input 0
                                    ,input 0
                                    ,input 0
                                    ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     ASSIGN
     add-option = '':U.
     RETURN NO-APPLY.
  END.
  ASSIGN
  add-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_else-rule
DO:
  ASSIGN
  add-option = 'ELSE-RULE':U.
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option
                                    ,INPUT '':U
                                    ,INPUT '':U
                                    ,input 0
                                    ,input 0
                                    ,input 0
                                    ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     ASSIGN
     add-option = '':U.
     RETURN NO-APPLY.
  END.
  ASSIGN
  add-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_goto
DO:
    ASSIGN
  add-option = 'GOTO':U.
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option
                                    ,INPUT '':U
                                    ,INPUT '':U
                                    ,input 0
                                    ,input 0
                                    ,input 0
                                    ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     ASSIGN
     add-option = '':U.
     RETURN NO-APPLY.
  END.
  ASSIGN
  add-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_goto0
DO:
    ASSIGN
  add-option = ('GOTO':U + chr(44) + "0").
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option
                                    ,INPUT '':U
                                    ,INPUT '':U
                                    ,input 0
                                    ,input 0
                                    ,input 0
                                    ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     ASSIGN
     add-option = '':U.
     RETURN NO-APPLY.
  END.
  ASSIGN
  add-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_rule
DO:
  ASSIGN
  add-option = 'RULE':U.
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option
                                    ,INPUT '':U
                                    ,INPUT '':U
                                    ,input 0
                                    ,input 0
                                    ,input 0
                                    ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     ASSIGN
     add-option = '':U.
     RETURN NO-APPLY.
  END.
  ASSIGN
  add-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_script
DO:
  ASSIGN
  move-option = "script".
  APPLY "CHOOSE" TO b-sel IN FRAME Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_script0
DO:
  ASSIGN
  move-option = "script0".
  APPLY "CHOOSE" TO b-sel IN FRAME Dialog-Frame.
END.
ON VALUE-CHANGED OF RS-language IN FRAME Dialog-Frame
DO:
  ASSIGN
   rs-language.
  RUN openbr IN THIS-PROCEDURE NO-ERROR.
END.
ON VALUE-CHANGED OF T-hidden IN FRAME Dialog-Frame
DO:
  ASSIGN
  t-hidden.
  CASE t-hidden:
    WHEN YES THEN DO:
        DISABLE
        b-add
        b-chg
        b-move
        b-del
        b-text
        WITH FRAME Dialog-Frame.
    END.
    WHEN NO THEN DO:
      IF p-mode <> 'ПРОСМОТР':U THEN DO:
        enable
        b-add
        b-chg
        b-move
        b-del
        b-text
        WITH FRAME Dialog-Frame.
      END.
    END.
  END CASE.
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse br-rule-script :handle
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if num-entries(p-mode) > 1 then do:
    assign
    v-is-admin-mode = logical(entry(2, p-mode)) no-error .
    p-mode = entry(1, p-mode).
  end.
  RUN fill-main-table IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
  IF p-mode <> 'ДОБАВЛЕНИЕ':U  THEN DO:
    RUN fill-tables IN THIS-PROCEDURE (  INPUT tt-rule.RULE_id
                                    ,INPUT tt-rule.root_RULE_id
                                    ,INPUT-OUTPUT v-level
                                    ,INPUT "") no-error.
    IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
  END.
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-rule SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY T-hidden RS-language
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-rule THEN
    DISPLAY tt-rule.rule_id tt-rule.codex_id tt-rule.reusable-params tt-rule.name
          tt-rule.image-file-name tt-rule.documentation
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit T-hidden b-print B-Help tt-rule.reusable-params B-codex
         tt-rule.name b-image tt-rule.documentation b-sel B-add B-del B-chg
         b-move B-text b-params RS-language br-rule-script
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-rule-script FOR EACH tt-rule-script WHERE     tt-rule-script.root_RULE_id  = tt-rule.RULE_id AND tt-rule-script.LANGUAGE = rs-language NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE fill-main-table :
DEFINE BUFFER buf_tt-ruledict-param FOR tt-ruledict-param.
DEFINE BUFFER buf_ruledict-param FOR ub.ruledict-param.
DEFINE BUFFER buf_ruledict FOR ub.ruledict.
define buffer buf_rule-i-script for ub.rule-i-script.
define buffer buf_tt-rule-i-script for tt-rule-i-script.
FOR EACH tt-rule:
  DELETE tt-rule.
END.
FOR EACH tt-rule-script:
  DELETE tt-rule-script.
END.
FOR EACH tt-rule-i-script:
  DELETE tt-rule-i-script.
END.
FOR EACH tt-ruledict-param:
  DELETE tt-ruledict-param.
END.
IF p-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
    FIND FIRST first_rule EXCLUSIVE-LOCK.
    CREATE tt-rule.
    ASSIGN
    tt-rule.upper_rule_id = 0
    tt-rule.RULE_id = next-value(s-rule-id, ub)
    tt-rule.root_rule_id = tt-rule.rule_id
    .
END.
else do:
  IF p-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
    FIND FIRST LOCKED_rule EXCLUSIVE-LOCK WHERE
              LOCKED_rule.RULE_id = p-rule-id.
    if locked_rule.upper_rule_id <> 0 then do:
      message
      "Нельзя вызвать интерейс редактирования для НЕКОРНЕВОГО (upper_rule_id <> 0) правила"
      view-as alert-box error .
      undo, return error .
    end.
    if v-is-admin-mode = no then do:
      run trg/rule-chk.p ( input 'ИЗМЕНЕНИЕ':U
                          ,input p-rule-id
                          ,output v-ok
                          ,output v-mess) no-error.
      if error-status:error
      or not v-ok then do:
        message
        "Нельзя изменить правило" skip
        error-status:get-message(1) skip
        v-mess
        view-as alert-box error .
        undo, return error .
      end.
    end.
    for each buf_rule-i-script where
            buf_rule-i-script.root_rule_id = p-rule-id:
      create buf_tt-rule-i-script.
      buffer-copy buf_rule-i-script
      to buf_tt-rule-i-script.
    end.
    FIND FIRST locked_ruledict EXCLUSIVE-LOCK WHERE
              locked_ruledict.ENTRY-type = 'rule':U
        AND locked_ruledict.uniq-key-rec = locked_rule.uniq-key-rec NO-ERROR.
  END.
  IF p-mode = 'ПРОСМОТР':U THEN DO:
      FIND FIRST LOCKED_rule no-lock WHERE
                LOCKED_rule.rule_id = p-rule-id.
      FIND FIRST locked_ruledict NO-LOCK WHERE
                locked_ruledict.ENTRY-type = 'rule':U
          AND locked_ruledict.uniq-key-rec = locked_rule.uniq-key-rec NO-ERROR.
      IF NOT AVAILABLE locked_ruledict THEN DO:
        MESSAGE
        substitute("Для правила &1 не найден термин в словаре", p-rule-id)
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
      END.
  END.
  create tt-rule.
  buffer-copy locked_rule to tt-rule.
  FOR EACH buf_ruledict-param NO-LOCK WHERE
        buf_ruledict-param.entry-id = locked_ruledict.ENTRY-id:
    CREATE buf_tt-ruledict-param.
    BUFFER-COPY buf_ruledict-param TO buf_tt-ruledict-param.
  END.
end.
END PROCEDURE.
PROCEDURE fill-tables :
DEFINE INPUT PARAMETER p-rule-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-root-rule-id AS INTEGER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-level AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-gen-order AS character NO-UNDO.
DEFINE BUFFER buf_rule FOR ub.RULE.
DEFINE BUFFER buf_rule-script FOR ub.RULE-script.
DEFINE BUFFER buf_tt-rule FOR tt-RULE.
DEFINE BUFFER buf_tt-rule-script FOR tt-RULE-script.
p-level = p-level + 1.
FOR EACH buf_rule NO-LOCK WHERE
        buf_rule.UPPER_rule_id = p-rule-id:
   find first buf_tt-rule where
            buf_tt-rule.rule_id = buf_rule.rule_id no-error.
   if not available buf_tt-rule then do:
    CREATE buf_tt-rule.
    buffer-copy buf_rule to buf_tt-rule.
    ASSIGN
    buf_tt-rule.root_rule_id = p-root-rule-id
    .
   end.
   buf_tt-rule.level = p-level.
   RUN fill-tables IN THIS-PROCEDURE (  INPUT buf_tt-rule.RULE_id
                                       ,INPUT p-root-rule-id
                                       ,INPUT-OUTPUT p-level
                                       ,INPUT (p-gen-order +
                                        STRING(p-level, "99") +
                                        STRING(buf_tt-rule.salience, "999"))).
END.
FOR EACH buf_rule-script NO-LOCK WHERE
        buf_rule-script.rule_id = p-rule-id:
   find first buf_tt-rule-script where
            buf_tt-rule-script.script_id = buf_rule-script.script_id
       AND  buf_tt-rule-script.LANGUAGE = buf_rule-script.LANGUAGE
       no-error.
   if not available buf_tt-rule-script
   then do:
    find first buf_tt-rule no-lock where
              buf_tt-rule.rule_id = buf_rule-script.rule_id.
    CREATE buf_tt-rule-script.
    buffer-copy buf_rule-script to buf_tt-rule-script.
    ASSIGN
    buf_tt-rule-script.root_rule_id = p-root-rule-id
    buf_tt-rule-script.upper_rule_id = buf_tt-rule.upper_rule_id
    .
   end.
   assign
   buf_tt-rule-script.level = p-level
   buf_tt-rule-script.gen-order = p-gen-order +
                                  STRING(buf_tt-rule-script.level, "99") +
                                  STRING(buf_tt-rule-script.salience, "999").
   .
END.
p-level = p-level - 1.
END PROCEDURE.
PROCEDURE fill-tt-ruledict-param :
DEFINE INPUT PARAMETER p-bh AS HANDLE NO-UNDO.
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
FOR EACH tt-ruledict-param
ON error  UNDO, RETURN ERROR
ON stop  UNDO, RETURN ERROR:
  ASSIGN
  glog = p-bh:BUFFER-CREATE() NO-ERROR.
  IF NOT glog THEN DO:
     UNDO, RETURN ERROR substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
  END.
  ASSIGN
  glog = p-bh:BUFFER-Copy( BUFFER tt-ruledict-param:HANDLE) NO-ERROR.
  IF NOT glog THEN DO:
     UNDO, RETURN ERROR substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
  END.
END.
END PROCEDURE.
PROCEDURE fill-tt-tables :
DEFINE INPUT PARAMETER p-rule-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-root-rule-id AS INTEGER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-level AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-gen-order AS character NO-UNDO.
DEFINE BUFFER buf_tt-rule FOR tt-RULE.
DEFINE BUFFER buf_tt-rule-script FOR tt-RULE-script.
p-level = p-level + 1.
FOR EACH buf_tt-rule NO-LOCK WHERE
        buf_tt-rule.UPPER_rule_id = p-rule-id:
   buf_tt-rule.level = p-level.
   RUN fill-tt-tables IN THIS-PROCEDURE (  INPUT buf_tt-rule.RULE_id
                                       ,INPUT p-root-rule-id
                                       ,INPUT-OUTPUT p-level
                                       ,INPUT (p-gen-order +
                                        STRING(p-level, "99") +
                                        STRING(buf_tt-rule.salience, "999"))).
END.
OUTPUT TO kk.txt.
FOR EACH buf_tt-rule-script NO-LOCK WHERE
        buf_tt-rule-script.rule_id = p-rule-id,
   FIRST buf_tt-rule WHERE buf_tt-rule.RULE_id = buf_tt-rule-script.RULE_id:
   assign
   buf_tt-rule-script.UPPER_rule_id = buf_tt-rule.UPPER_rule_id
   buf_tt-rule-script.level = p-level
   buf_tt-rule-script.gen-order = p-gen-order +
                                  STRING(buf_tt-rule-script.level, "99") +
                                  STRING(buf_tt-rule-script.salience, "999").
   .
   EXPORT buf_tt-rule-script.
END.
OUTPUT CLOSE.
p-level = p-level - 1.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-h AS WIDGET-HANDLE NO-UNDO.
assign
rs-language:radio-buttons in frame Dialog-Frame = "ABL" + chr(44) + "ABL" + chr(44) +
                                                   "rus" + chr(44) + "rus"
v-h = br-rule-script:FIRST-COLUMN IN FRAME Dialog-Frame
b-add:menu-mouse IN FRAME Dialog-Frame = 1
b-sel:menu-mouse IN FRAME Dialog-Frame = 1
.
tt-rule-script.gen-order:RESIZABLE IN BROWSE br-rule-script = YES.
DO while valid-handle(v-h) :
  if v-h:LABEL = "Выражение" then do:
    v-h:RESIZABLE = YES.
    LEAVE.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.
ASSIGN
t-hidden = tt-rule.HIDDEN-content > 0
.
DISPLAY RS-language
WITH FRAME Dialog-Frame .
IF AVAILABLE tt-rule THEN
DISPLAY
tt-rule.rule_id
tt-rule.reusable-params
tt-rule.codex_id
tt-rule.documentation
tt-rule.name
t-HIDDEN
tt-rule.image-file-name
WITH FRAME Dialog-Frame .
ENABLE
B-exit  when p-mode <> 'ПРОСМОТР':U
b-quit
tt-rule.reusable-params when p-mode <> 'ПРОСМОТР':U
B-Help
tt-rule.name
tt-rule.documentation
b-image when p-mode <> 'ПРОСМОТР':U
RS-language
B-add   when p-mode <> 'ПРОСМОТР':U
B-del   when p-mode <> 'ПРОСМОТР':U
B-chg   when p-mode <> 'ПРОСМОТР':U
B-move   when p-mode <> 'ПРОСМОТР':U
B-text   when p-mode <> 'ПРОСМОТР':U
t-hIDDEN WHEN p-mode <> 'ПРОСМОТР':U
b-print
b-codex WHEN (p-mode <> 'ПРОСМОТР':U
              AND NOT CAN-FIND (FIRST ub.rule-i-script WHERE
                                      ub.rule-script.RULE_id = tt-rule.RULE_id)
              AND NOT CAN-FIND (FIRST ub.rule WHERE
                                      ub.rule.upper_RULE_id = tt-rule.RULE_id)
              AND NOT CAN-FIND (FIRST ub.rule-script WHERE
                                      ub.rule-script.RULE_id = tt-rule.RULE_id)
             )
br-rule-script
b-params
WITH FRAME Dialog-Frame .
ASSIGN
tt-rule.documentation:READ-ONLY IN FRAME Dialog-Frame = (p-mode = 'ПРОСМОТР':U)
tt-rule.name:READ-ONLY IN FRAME Dialog-Frame = (p-mode = 'ПРОСМОТР':U).
if p-mode = 'ПРОСМОТР':U then do:
  hide
  b-exit
  b-add
  b-chg
  b-del
  b-move
  in frame Dialog-Frame .
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1.
  if tt-rule.codex_id <> 19 then do:
    hide
    b-image
    tt-rule.image-file-name
    in frame Dialog-Frame .
  end.
end.
VIEW FRAME Dialog-Frame .
APPLY "VALUE-CHANGED" to t-hidden.
RUN Openbr IN THIS-PROCEDURE NO-ERROR.
END PROCEDURE.
PROCEDURE openbr :
OPEN QUERY br-rule-script FOR EACH tt-rule-script NO-LOCK  WHERE
    tt-rule-script.root_RULE_id  = tt-rule.RULE_id
AND tt-rule-script.LANGUAGE = rs-language
BY tt-rule-script.gen-order
INDEXED-REPOSITION.
APPLY "ENTRY" to browse br-rule-script .
APPLY "VALUE-CHANGED" to browse br-rule-script.
END PROCEDURE.
PROCEDURE proc-aff-move :
define input parameter p-move-rule-id as integer no-undo .
define input parameter p-move-script-id as integer no-undo .
define input parameter p-dest-rule-id as integer no-undo .
define input parameter p-dest-script-id as integer no-undo .
define input parameter p-move-option as character no-undo .
DEFINE VARIABLE v-add-option AS CHARACTER NO-UNDO extent 3.
DEFINE VARIABLE v-script-al AS CHARACTER NO-UNDO  extent 3.
DEFINE VARIABLE v-script-nl AS CHARACTER NO-UNDO extent 3.
define variable v-script-type as character no-undo  extent 3.
define variable v-script-id as integer no-undo extent 3.
define variable v-rule-id as integer no-undo extent 3.
DEFINE BUFFER MOVE_tt-rule-script FOR tt-rule-script.
DEFINE BUFFER MOVE2_tt-rule-script FOR tt-rule-script.
DEFINE BUFFER dest_tt-rule-script FOR tt-rule-script.
define buffer move_tt-rule  for tt-rule.
FOR each MOVE_tt-rule-script WHERE
           MOVE_tt-rule-script.RULE_id = p-move-rule-id
      AND  MOVE_tt-rule-script.script_id = p-move-script-id:
  IF MOVE_tt-rule-script.LANGUAGE = "ABL" THEN DO:
     v-script-al[1] = MOVE_tt-rule-script.script.
     v-script-type[1] = move_tt-rule-script.script-type.
  END.
  IF MOVE_tt-rule-script.LANGUAGE = "rus" THEN DO:
     v-script-nl[1] = MOVE_tt-rule-script.script.
  END.
  case  move_tt-rule-script.script-type:
    when 'COND':U
    or
    when 'CYCLE-COND':U
    then do:
      for each move2_tt-rule-script where
          move2_tt-rule-script.rule_id = move_tt-rule-script.rule_id
      and move2_tt-rule-script.salience > move_tt-rule-script.salience :
        if move2_tt-rule-script.script-type = 'RULE':U
        and v-script-type[2] = '':U
        then do:
          v-add-option[2] = 'RULE':U.
          v-script-al[2] = MOVE2_tt-rule-script.script.
          v-script-type[2] = move2_tt-rule-script.script-type.
          v-script-nl[2] = MOVE2_tt-rule-script.script.
          v-script-id[2] = MOVE2_tt-rule-script.script_id.
          find first move_tt-rule  where
                    move_tt-rule.upper_rule_id = move2_tt-rule-script.rule_id
               and  move_tt-rule.salience = move2_tt-rule-script.salience.
          v-rule-id[2] = move_tt-rule.rule_id.
        end.
        if move2_tt-rule-script.script-type = 'ELSE-RULE':U
        and v-script-type[3] = '':U
        then do:
          v-add-option[3] = 'ELSE-RULE':U.
          v-script-al[3] = MOVE2_tt-rule-script.script.
          v-script-type[3] = move2_tt-rule-script.script-type.
          v-script-nl[3] = MOVE2_tt-rule-script.script.
          v-script-id[3] = MOVE2_tt-rule-script.script_id.
          find first move_tt-rule  where
                    move_tt-rule.upper_rule_id = move2_tt-rule-script.rule_id
               and  move_tt-rule.salience = move2_tt-rule-script.salience.
          v-rule-id[3] = move_tt-rule.rule_id.
        end.
      end.
    end.
  end case.
END.
FIND FIRST dest_tt-rule-script WHERE
           dest_tt-rule-script.RULE_id = p-dest-rule-id
      AND  dest_tt-rule-script.script_id = p-dest-script-id.
case p-move-option:
  WHEN "script" THEN DO:
    IF v-script-type[1] = 'COND':U THEN DO:
      v-add-option[1] = 'COND':U.
    END.
    IF v-script-type[1] = 'CYCLE-COND':U THEN DO:
      v-add-option[1] = 'CYCLE-COND':U.
    END.
    IF v-script-type[1] = 'CONS':U THEN DO:
      v-add-option[1] = 'CONS':U.
    END.
    IF v-script-type[1] = 'GOTO':U THEN DO:
      v-add-option[1] = 'GOTO':U.
    END.
  END.
  WHEN "script0" THEN DO:
    IF v-script-type[1] = 'COND':U THEN DO:
        v-add-option[1] = ('COND':U + chr(44) + "0").
    END.
    IF v-script-type[1] = 'CYCLE-COND':U THEN DO:
        v-add-option[1] = ('CYCLE-COND':U + chr(44) + "0").
    END.
    IF v-script-type[1] = 'CONS':U THEN DO:
        v-add-option[1] = ('CONS':U + chr(44) + "0").
    END.
    IF v-script-type[1] = 'GOTO':U THEN DO:
        v-add-option[1] = ('GOTO':U + chr(44) + "0").
    END.
  END.
END CASE.
do transaction:
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT v-add-option[1]
                                    ,INPUT v-script-al[1]
                                    ,INPUT v-script-nl[1]
                                    ,input p-move-script-id
                                    ,input 0
                                    ,input 0
                                    ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    RETURN.
  END.
  if v-add-option[2] <> '':U then do:
    RUN proc-b-add IN THIS-PROCEDURE ( INPUT v-add-option[2]
                                      ,INPUT v-script-al[2]
                                      ,INPUT v-script-nl[2]
                                      ,input v-script-id[2]
                                      ,input v-rule-id[2]
                                      ,input p-move-script-id
                                      ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      RETURN.
    END.
  end.
  if v-add-option[3] <> '':U then do:
    RUN proc-b-add IN THIS-PROCEDURE ( INPUT v-add-option[3]
                                      ,INPUT v-script-al[3]
                                      ,INPUT v-script-nl[3]
                                      ,input v-script-id[3]
                                      ,input v-rule-id[3]
                                      ,input p-move-script-id
                                      ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      RETURN.
    END.
  end.
  if not v-add-option[1] begins 'COND':U
  and not v-add-option[1] begins 'CYCLE-COND':U
  then do:
    FOR each MOVE_tt-rule-script WHERE
              MOVE_tt-rule-script.RULE_id = p-move-rule-id
          AND  MOVE_tt-rule-script.script_id = p-move-script-id:
      RUN proc-b-del IN THIS-PROCEDURE ( INPUT p-move-rule-id
                                        ,INPUT p-move-script-id).
    END.
  end.
end.
END PROCEDURE.
PROCEDURE proc-b-add :
DEFINE INPUT PARAMETER p-add-option AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-move-script-al AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-move-script-nl AS CHARACTER NO-UNDO.
define input parameter p-move-script-id as integer no-undo .
define input parameter p-move-rule-id as integer no-undo .
define input parameter p-move-cond-id as integer no-undo .
DEFINE VARIABLE v-add-option AS character NO-UNDO.
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-upper-rule-id AS INTEGER.
DEFINE VARIABLE v-rule-id AS INTEGER.
DEFINE VARIABLE v-script-id AS INTEGER.
define variable v-salience as integer no-undo .
define variable v-level as integer no-undo .
DEFINE BUFFER buf_tt-rule FOR tt-rule.
DEFINE BUFFER buf2_tt-rule FOR tt-rule.
DEFINE BUFFER buf_tt-rule-script FOR tt-rule-script.
DEFINE BUFFER buf2_tt-rule-script FOR tt-rule-script.
DEFINE BUFFER buf_tt-l_rule-script FOR tt-rule-script.
DEFINE BUFFER bufm_tt-l_rule-script FOR tt-rule-script.
DEFINE BUFFER bufm_tt-rule-script FOR tt-rule-script.
define buffer buf_tt-rule-i-script for tt-rule-i-script.
define buffer bufm_tt-rule-i-script for tt-rule-i-script.
IF tt-rule.codex_id = 0  THEN DO:
     MESSAGE
     "Для редактирования необходимо сначала выбрать кодекс правил"
      VIEW-AS ALERT-BOX ERROR.
     RETURN NO-APPLY.
 END.
IF AVAILABLE tt-rule-script THEN DO:
  v-rec = RECID(tt-rule-script).
END.
CASE p-add-option:
  WHEN 'RULE':U THEN DO:
    v-add-option = 'RULE':U.
    if p-move-rule-id = 0 then do:
      IF NOT AVAILABLE tt-rule-script THEN DO:
        assign
        v-upper-rule-id = tt-rule.rule_id
        v-rule-id = 0
        v-salience =0
        .
      END.
      ELSE DO:
        assign
        v-upper-rule-id = tt-rule-script.rule_id
        v-rule-id = 0
        v-salience = tt-rule-script.salience + 1
        .
      END.
      create buf_tt-rule.
      assign
      buf_tt-rule.upper_rule_id = v-upper-rule-id
      buf_tt-rule.root_rule_id = tt-rule.root_rule_id
      buf_tt-rule.name = '':U
      buf_tt-rule.documentation = '':U
      buf_tt-rule.salience = v-salience
      buf_tt-rule.codex_id = tt-rule.codex_id
      buf_tt-rule.RULE_id = next-value(s-rule-id, ub)
      .
      IF NOT AVAILABLE tt-rule-script THEN DO:
        assign
        v-rule-id = tt-rule.rule_id
        v-salience =0
        .
      END.
      ELSE DO:
        assign
        v-rule-id = tt-rule-script.rule_id
        v-salience = tt-rule-script.salience + 1
        .
      END.
      CREATE buf_tt-rule-script.
      ASSIGN
      v-script-id = next-value(s-rule-script-id, ub)
      buf_tt-rule-script.script_id = v-script-id
      buf_tt-rule-script.RULE_id = v-rule-id
      buf_tt-rule-script.root_RULE_id = buf_tt-rule.root_rule_id
      buf_tt-rule-script.salience = v-salience
      buf_tt-rule-script.script-type = 'RULE':U
      buf_tt-rule-script.LANGUAGE = "ABL".
      RELEASE buf_tt-rule-script.
      CREATE buf_tt-l_rule-script.
      ASSIGN
      buf_tt-l_rule-script.script_id = v-script-id
      buf_tt-l_rule-script.RULE_id = v-rule-id
      buf_tt-l_rule-script.root_RULE_id = tt-rule.root_rule_id
      buf_tt-l_rule-script.salience = v-salience
      buf_tt-l_rule-script.script-type = 'RULE':U
      buf_tt-l_rule-script.LANGUAGE = "rus".
      RELEASE buf_tt-l_rule-script.
    end.
    else do:
      find first buf_tt-rule-script where
                buf_tt-rule-script.script_id = p-move-cond-id .
      assign
      v-upper-rule-id = buf_tt-rule-script.rule_id
      v-salience = buf_tt-rule-script.salience + 1
      .
      find first buf_tt-rule where buf_tt-rule.rule_id = p-move-rule-id.
      assign
      buf_tt-rule.upper_rule_id = v-upper-rule-id
      buf_tt-rule.salience = v-salience
      .
      find first buf_tt-rule-script where
                buf_tt-rule-script.script_id = p-move-script-id
            and buf_tt-rule-script.language = "ABL".
      ASSIGN
      buf_tt-rule-script.RULE_id = v-rule-id
      buf_tt-rule-script.salience = v-salience
      .
      RELEASE buf_tt-rule-script.
      find first buf_tt-l_rule-script where
                buf_tt-l_rule-script.script_id = p-move-script-id
            and buf_tt-l_rule-script.language = "rus".
      ASSIGN
      buf_tt-l_rule-script.RULE_id = v-rule-id
      buf_tt-l_rule-script.salience = v-salience.
      RELEASE buf_tt-l_rule-script.
    end.
  END.
  WHEN 'ELSE-RULE':U THEN DO:
    v-add-option = 'ELSE-RULE':U.
    IF NOT AVAILABLE tt-rule-script THEN DO:
      message "Нельзя создать" view-as alert-box error .
      return error.
    END.
    ELSE DO:
      assign
      v-upper-rule-id = tt-rule-script.rule_id
      v-rule-id = 0
      v-salience = tt-rule-script.salience + 1
      .
    END.
    if p-move-rule-id = 0 then do:
      create buf_tt-rule.
      assign
      buf_tt-rule.upper_rule_id = v-upper-rule-id
      buf_tt-rule.root_rule_id = tt-rule.root_rule_id
      buf_tt-rule.name = '':U
      buf_tt-rule.documentation = '':U
      buf_tt-rule.salience = v-salience
      buf_tt-rule.codex_id = tt-rule.codex_id
      buf_tt-rule.RULE_id = next-value(s-rule-id, ub)
      .
      assign
      v-rule-id = tt-rule-script.rule_id
      v-salience = tt-rule-script.salience + 1
      .
      CREATE buf_tt-rule-script.
      ASSIGN
      v-script-id = next-value(s-rule-script-id, ub)
      buf_tt-rule-script.script_id = v-script-id
      buf_tt-rule-script.RULE_id = v-rule-id
      buf_tt-rule-script.root_RULE_id = buf_tt-rule.root_rule_id
      buf_tt-rule-script.salience = v-salience
      buf_tt-rule-script.script-type = 'ELSE-RULE':U
      buf_tt-rule-script.LANGUAGE = "ABL".
      RELEASE buf_tt-rule-script.
      CREATE buf_tt-l_rule-script.
      ASSIGN
      buf_tt-l_rule-script.script_id = v-script-id
      buf_tt-l_rule-script.RULE_id = v-rule-id
      buf_tt-l_rule-script.root_RULE_id = tt-rule.root_rule_id
      buf_tt-l_rule-script.salience = v-salience
      buf_tt-l_rule-script.script-type = 'ELSE-RULE':U
      buf_tt-l_rule-script.LANGUAGE = "rus".
      RELEASE buf_tt-l_rule-script.
    end.
    else do:
      find first buf_tt-rule where buf_tt-rule.rule_id = p-move-rule-id.
      assign
      buf_tt-rule.upper_rule_id = v-upper-rule-id
      buf_tt-rule.salience = v-salience
      .
      assign
      v-rule-id = tt-rule-script.rule_id
      v-salience = tt-rule-script.salience + 1
      .
      find first buf_tt-rule-script where
                buf_tt-rule-script.script_id = p-move-script-id
            and buf_tt-rule-script.language = "ABL".
      ASSIGN
      buf_tt-rule-script.RULE_id = v-rule-id
      buf_tt-rule-script.salience = v-salience.
      RELEASE buf_tt-rule-script.
      find first buf_tt-l_rule-script where
                buf_tt-l_rule-script.script_id = p-move-script-id
            and buf_tt-l_rule-script.language = "rus".
      ASSIGN
      buf_tt-l_rule-script.RULE_id = v-rule-id
      buf_tt-l_rule-script.salience = v-salience.
      RELEASE buf_tt-l_rule-script.
    end.
  END.
  WHEN 'CONS':U
  or
  WHEN ('CONS':U + chr(44) + "0")
  or
  WHEN 'GOTO':U
  or
  WHEN ('GOTO':U + chr(44) + "0")
  THEN DO:
     if p-add-option begins 'CONS':U then do:
       v-add-option = 'CONS':U.
     end.
     if p-add-option begins 'GOTO':U then do:
       v-add-option = 'GOTO':U.
     end.
     IF NOT AVAILABLE tt-rule-script THEN DO:
       assign
       v-upper-rule-id = tt-rule.UPPER_rule_id
       v-rule-id = tt-rule.RULE_id
       v-salience = 0
       .
     END.
     ELSE DO:
       if (tt-rule-script.script-type = 'RULE':U
       or tt-rule-script.script-type = 'ELSE-RULE':U)
       AND (p-add-option = 'CONS':U
            or
            p-add-option = 'GOTO':U)
       then do:
         find first buf_tt-rule no-lock where
                   buf_tt-rule.upper_RULE_id = tt-rule-script.RULE_id
              and  buf_tt-rule.salience = tt-rule-script.salience  .
         assign
         v-upper-rule-id = buf_tt-rule.UPPER_rule_id
         v-rule-id = buf_tt-rule.RULE_id
         v-salience = 0.
       end.
       else do:
         FIND FIRST buf_tt-rule NO-LOCK WHERE
                   buf_tt-rule.RULE_id = tt-rule-script.RULE_id.
        assign
        v-upper-rule-id = buf_tt-rule.UPPER_rule_id.
        v-rule-id = buf_tt-rule.RULE_id.
        v-salience = tt-rule-script.salience + 1
       .
      end.
    eND.
  END.
  WHEN 'COND':U
  or
  WHEN ('COND':U + chr(44) + "0")
  or
  when 'CYCLE-COND':U
  or
  when ('CYCLE-COND':U + chr(44) + "0")
  THEN DO:
     v-add-option = entry(1, p-add-option).
     IF NOT AVAILABLE tt-rule-script THEN DO:
       assign
       v-upper-rule-id = tt-rule.upper_rule_id
       v-rule-id = tt-rule.RULE_id
       v-salience =  0
       .
     END.
     ELSE DO:
       if (tt-rule-script.script-type = 'RULE':U
       or tt-rule-script.script-type = 'ELSE-RULE':U)
       AND (p-add-option = 'COND':U
            or
            p-add-option = 'CYCLE-COND':U)
       then do:
         find first buf_tt-rule no-lock where
                   buf_tt-rule.upper_RULE_id = tt-rule-script.RULE_id
              and  buf_tt-rule.salience = tt-rule-script.salience  .
         assign
         v-upper-rule-id = buf_tt-rule.UPPER_rule_id
         v-rule-id = buf_tt-rule.RULE_id
         v-salience = 0.
       end.
       else do:
        FIND FIRST buf_tt-rule NO-LOCK WHERE
            buf_tt-rule.RULE_id = tt-rule-script.RULE_id.
        assign
        v-upper-rule-id = buf_tt-rule.UPPER_rule_id
        v-rule-id = buf_tt-rule.RULE_id
        v-salience = tt-rule-script.salience + 1
        .
      end.
    END.
  END.
END CASE.
 IF p-add-option = 'RULE':U
 or p-add-option = 'ELSE-RULE':U
 THEN DO:
   ERROR-STATUS:ERROR = NO.
 END.
 ELSE DO:
   IF p-move-script-id = 0 THEN DO:
       run rul/updrule.w ( INPUT parparentproc
                              ,input  'ДОБАВЛЕНИЕ':U
                              ,INPUT tt-rule.codex_id
                              ,input tt-rule.root_rule_id
                              ,input v-upper-rule-id
                              ,input v-rule-id
                              ,INPUT v-add-option
                              ,input v-salience
                              ,INPUT-OUTPUT v-script-id
                              ) NO-ERROR.
   END.
   ELSE DO:
     if p-move-script-id = 0
     or p-add-option begins 'CONS':U
     or p-add-option begins 'GOTO':U
     then do:
      v-script-id = next-value(s-rule-script-id, ub).
      CREATE bufm_tt-rule-script.
      ASSIGN
      bufm_tt-rule-script.script_id = v-script-id
      bufm_tt-rule-script.RULE_id = v-rule-id
      bufm_tt-rule-script.root_RULE_id = tt-rule.root_rule_id
      bufm_tt-rule-script.salience = v-salience
      bufm_tt-rule-script.script-type = v-add-option
      bufm_tt-rule-script.LANGUAGE = "ABL"
      bufm_tt-rule-script.script = p-move-script-al
      .
      CREATE bufm_tt-l_rule-script.
      ASSIGN
      bufm_tt-l_rule-script.script_id = v-script-id
      bufm_tt-l_rule-script.RULE_id = v-rule-id
      bufm_tt-l_rule-script.root_RULE_id = tt-rule.root_rule_id
      bufm_tt-l_rule-script.salience = v-salience
      bufm_tt-l_rule-script.script-type = v-add-option
      bufm_tt-l_rule-script.LANGUAGE = "rus"
      bufm_tt-l_rule-script.script = p-move-script-nl
      .
      for each bufm_tt-rule-i-script where
              bufm_tt-rule-i-script.root_rule_id = tt-rule.root_rule_id
          and bufm_tt-rule-i-script.script_id = p-move-script-id
      on error undo, return error:
        create  buf_tt-rule-i-script.
        buffer-copy bufm_tt-rule-i-script
        except script_id to buf_tt-rule-i-script
        assign
        buf_tt-rule-i-script.script_id = v-script-id
        .
        delete bufm_tt-rule-i-script.
      end.
      RELEASE bufm_tt-l_rule-script.
      RELEASE bufm_tt-rule-script.
    END.
    else do:
      find first bufm_tt-rule-script where
                bufm_tt-rule-script.script_id = p-move-script-id
            and bufm_tt-rule-script.LANGUAGE = "ABL".
      ASSIGN
      bufm_tt-rule-script.RULE_id = v-rule-id
      bufm_tt-rule-script.salience = v-salience
      .
      find first bufm_tt-l_rule-script where
                bufm_tt-l_rule-script.script_id = p-move-script-id
            and bufm_tt-l_rule-script.LANGUAGE = "rus".
      ASSIGN
      bufm_tt-l_rule-script.RULE_id = v-rule-id
      bufm_tt-l_rule-script.salience = v-salience
      .
      RELEASE bufm_tt-l_rule-script.
      RELEASE bufm_tt-rule-script.
    end.
  end.
 END.
 IF NOT ERROR-STATUS:ERROR THEN DO:
   repeat preselect each buf_tt-rule-script WHERE
           buf_tt-rule-script.rule_id = v-rule-id:
     find next buf_tt-rule-script.
     if available buf_tt-rule-script
     and  buf_tt-rule-script.salience >= v-salience then do:
       if buf_tt-rule-script.script_id = v-script-id then do:
         next.
       end.
       else do:
         if buf_tt-rule-script.script-type = 'RULE':U
         or buf_tt-rule-script.script-type = 'ELSE-RULE':U
         then do:
           find first buf2_tt-rule where
                     buf2_tt-rule.upper_rule_id = buf_tt-rule-script.rule_id
                and  buf2_tt-rule.salience = buf_tt-rule-script.salience no-error .
         end.
         ASSIGN
         buf_tt-rule-script.salience = buf_tt-rule-script.salience + 1
         .
         if available buf2_tt-rule then do:
          ASSIGN
          buf2_tt-rule.salience = buf2_tt-rule.salience + 1
          .
          release buf2_tt-rule.
         end.
       end.
     end.
   END.
   RUN fill-tt-tables IN THIS-PROCEDURE (  INPUT tt-rule.RULE_id
                                        ,INPUT tt-rule.root_RULE_id
                                        ,INPUT-OUTPUT v-level
                                        ,INPUT "") no-error.
END.
ASSIGN
add-option = '':U.
RUN openbr IN THIS-PROCEDURE NO-ERROR.
REPOSITION br-rule-script TO RECID v-rec NO-ERROR.
APPLY "VALUE-CHANGED" to browse br-rule-script.
END PROCEDURE.
PROCEDURE proc-b-del :
define input parameter p-rule-id as integer no-undo .
define input parameter p-script-id as integer no-undo .
define variable v-delete-rule as logical no-undo .
define buffer buf_tt-rule for tt-rule.
define buffer buf2_tt-rule for tt-rule.
DEFINE BUFFER buf_tt-rule-script FOR tt-rule-script.
DEFINE BUFFER buf2_tt-rule-script FOR tt-rule-script.
define buffer buf_tt-rule-i-script for tt-rule-i-script.
do
on error undo, return error
:
  find first buf_tt-rule where buf_tt-rule.rule_id = p-rule-id.
  find first buf_tt-rule-script where
            buf_tt-rule-script.script_id = p-script-id.
  if buf_tt-rule-script.script-type = 'RULE':U
  or buf_tt-rule-script.script-type = 'ELSE-RULE':U
  then do:
     find first buf2_tt-rule where
              buf2_tt-rule.upper_rule_id = p-rule-id
         and  buf2_tt-rule.salience = buf_tt-rule-script.salience.
     v-delete-rule = yes.
  end.
  if (buf_tt-rule-script.script-type = 'COND':U
      or
      buf_tt-rule-script.script-type = 'CYCLE-COND':U)
  and buf_tt-rule-script.rule_id <> buf_tt-rule-script.root_rule_id
  then do:
    for each buf2_tt-rule-script where
            buf2_tt-rule-script.rule_id = buf_tt-rule-script.rule_id
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    :
      if buf2_tt-rule-script.script_id = p-script-id
      or buf2_tt-rule-script.script-type = 'RULE':U
      or buf2_tt-rule-script.script-type = 'ELSE-RULE':U
      or buf2_tt-rule-script.salience < buf_tt-rule-script.salience
      or buf2_tt-rule-script.salience >  buf_tt-rule-script.salience + 1
      then do:
        next.
      end.
      message
      substitute("Вы пытаетесь удалить условие (1-ю строку) подправила  &1, которое содержит другие строки(&2)&3" +
                 "это недопустимо"
                 ,buf_tt-rule-script.rule_id
                 ,buf2_tt-rule-script.script_id
                 , chr(10))
      view-as alert-box error .
      undo, return error .
    end.
  end.
  FIND last buf2_tt-rule-script WHERE
      buf2_tt-rule-script.root_RULE_id  = buf_tt-rule.RULE_id
  AND buf2_tt-rule-script.LANGUAGE = rs-language
  AND ((buf2_tt-rule-script.level = buf_tt-rule.level
  AND buf2_tt-rule-script.salience < buf_tt-rule-script.salience)
      OR
      buf2_tt-rule-script.level < buf_tt-rule.level ) NO-ERROR.
  for each buf_tt-rule-i-script where
          buf_tt-rule-i-script.root_rule_id = tt-rule.rule_id
      and buf_tt-rule-i-script.script_id = p-script-id
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    delete buf_tt-rule-i-script.
  end.
  for each buf_tt-rule-script where
          buf_tt-rule-script.script_id = p-script-id
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    DELETE buf_tt-rule-script.
  end.
  if v-delete-rule then do:
    delete buf2_tt-rule.
  end.
end.
RUN OpenBr IN THIS-PROCEDURE NO-ERROR.
IF AVAILABLE buf2_tt-rule-script  THEN DO:
  REPOSITION br-rule-script TO RECID RECID(buf2_tt-rule-script) NO-ERROR.
END.
END PROCEDURE.
PROCEDURE proc-b-move :
define input parameter p-rule-id as integer no-undo .
define input parameter p-script-id as integer no-undo .
FIND FIRST MOVE_tt-rule-script WHERE
          recid(MOVE_tt-rule-script) = RECID(tt-rule-script).
IF MOVE_tt-rule-script.script-type = 'RULE':U
or MOVE_tt-rule-script.script-type = 'ELSE-RULE':U THEN DO:
  MESSAGE
  substitute("Нельзя переносить скрипты типа &1", MOVE_tt-rule-script.script-type)
  VIEW-AS ALERT-BOX ERROR.
  RELEASE MOVE_tt-rule-script.
  RETURN ERROR.
END.
HIDE
b-add IN FRAME Dialog-Frame
b-del
b-params
b-move
IN FRAME Dialog-Frame.
ENABLE
b-sel
WITH FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-params :
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-return-value as character no-undo .
DEFINE BUFFER buf_tt-ruledict-param FOR tt-ruledict-param.
IF p-mode = 'ПРОСМОТР':U THEN DO:
  FIND FIRST buf_tt-ruledict-param NO-ERROR.
  IF NOT AVAILABLE buf_tt-ruledict-param THEN DO:
    MESSAGE
    "У этого правила нет параметров"
    VIEW-AS ALERT-BOX.
    RETURN.
  END.
END.
ELSE DO:
  v-param-num-list = '':U.
END.
run rul/ruledict-param-s.w ( INPUT parparentproc
                            ,input this-procedure:handle
                            ,INPUT (IF p-mode = 'ИЗМЕНЕНИЕ':U
                                    OR p-mode = 'ДОБАВЛЕНИЕ':U
                                    THEN "b-add"
                                    ELSE "":U)
                            ,INPUT (if p-mode = 'ПРОСМОТР':U
                                    then "entry-id"
                                    else 'ИЗМЕНЕНИЕ':U)
                            ,INPUT (if p-mode = 'ИЗМЕНЕНИЕ':U
                                    or p-mode = 'ПРОСМОТР':U
                                    then locked_ruledict.entry-id
                                    else 0)
                            ,input 'rule':U
                            ,INPUT-OUTPUT v-rid-list) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
   UNDO, RETURN ERROR.
END.
v-return-value = return-value .
if (p-mode = 'ИЗМЕНЕНИЕ':U
or p-mode = 'ДОБАВЛЕНИЕ':U)
and v-return-value <> "quit" then do:
  FOR EACH tt-ruledict-param:
    IF LOOKUP(string(tt-ruledict-param.param-num), v-param-num-list) = 0 THEN DO:
        DELETE tt-ruledict-param.
    END.
  END.
end.
END PROCEDURE.
PROCEDURE proc-b-print :
run waitfram-show in this-procedure ( "Ждите..." ).
output to value (string(p-rule-id, "999999999") + ".rul-str").
DEFINE BUFFER buf_tt-rule-script FOR tt-rule-script.
for each buf_tt-rule-script no-lock where
        buf_tt-rule-script.root_rule_id = p-rule-id
    and buf_tt-rule-script.language = rs-language
   by buf_tt-rule-script.gen-order:
  export
  buf_tt-rule-script.rule_id    "~t"
  buf_tt-rule-script.gen-order        "~t"
  buf_tt-rule-script.level            "~t"
  buf_tt-rule-script.upper_rule_id    "~t"
  buf_tt-rule-script.script-type      "~t"
  buf_tt-rule-script.script_id        "~t"
  buf_tt-rule-script.salience         "~t"
  (fill(chr(32), buf_tt-rule-script.level * 2)  + buf_tt-rule-script.script) skip.
end.
output close.
run waitfram-hide in this-procedure .
END PROCEDURE.
PROCEDURE proc-cancel-move :
move-option = '':U.
RELEASE MOVE_tt-rule-script.
HIDE
b-sel IN FRAME Dialog-Frame.
ENABLE
b-add
b-del
b-chg
b-params
b-move
WITH FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
IF p-mode = 'ПРОСМОТР':U THEN DO:
  RETURN error.
END.
IF p-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
  v-rec = p-rec.
END.
ASSIGN
FRAME Dialog-Frame
tt-rule.NAME
tt-rule.codex_id
tt-rule.reusable-params
tt-rule.documentation
tt-rule.image-file-name
t-hidden
tt-rule.hidden-content = (IF t-hidden = YES THEN 1 ELSE 0)
.
run rul/rule1.p ( INPUT (p-mode + chr(44) + string(v-is-admin-mode))
                ,INPUT NO
                ,INPUT-OUTPUT v-rec
                ,INPUT tt-rule.rule_id
                ,INPUT tt-rule.codex_id
                ,INPUT tt-rule.upper_rule_id
                ,INPUT tt-rule.root_rule_id
                ,INPUT tt-rule.reusable-params
                ,INPUT tt-rule.salience
                ,INPUT tt-rule.name
                ,INPUT tt-rule.documentation
                ,input tt-rule.no-save-mode
                ,INPUT tt-rule.hidden-content
                ,input tt-rule.image-file-name
                ,input table tt-rule
                ,input table tt-rule-script
                ,input table tt-rule-i-script
                ,input table tt-ruledict-param
              ) no-error.
if error-status:error then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
PROCEDURE save-tt-ruledict-param :
DEFINE INPUT PARAMETER p-bh AS HANDLE NO-UNDO.
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
FIND FIRST tt-ruledict-param WHERE
           tt-ruledict-param.param-num = p-bh::param-num NO-ERROR.
IF NOT AVAILABLE tt-ruledict-param THEN DO:
   CREATE tt-ruledict-param.
END.
ASSIGN
glog = BUFFER tt-ruledict-param:handle:BUFFER-Copy( p-bh) NO-ERROR.
IF NOT glog THEN DO:
  UNDO, RETURN ERROR substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
END.
v-param-num-list = v-param-num-list + chr(44) + STRING( tt-ruledict-param.param-num).
END PROCEDURE.
PROCEDURE switch-rule :
IF NOT AVAILABLE tt-rule-script
OR not (tt-rule-script.script-type = 'COND':U
       or
       tt-rule-script.script-type = 'CYCLE-COND':U) THEN DO:
  MENU-ITEM m_rule:SENSITIVE IN MENU menu-b-add = NO .
END.
ELSE DO:
   MENU-ITEM m_rule:SENSITIVE IN MENU menu-b-add = yes .
END.
IF NOT AVAILABLE tt-rule-script
OR not tt-rule-script.script-type = 'RULE':U then do:
  MENU-ITEM m_else-rule:SENSITIVE IN MENU menu-b-add = NO .
end.
else do:
  MENU-ITEM m_else-rule:SENSITIVE IN MENU menu-b-add = yes .
end.
IF AVAILABLE tt-rule-script
AND (tt-rule-script.script-type = 'RULE':U
or  tt-rule-script.script-type = 'ELSE-RULE':U )
THEN DO:
  ASSIGN
  MENU-ITEM m_cond:SENSITIVE IN MENU menu-b-add = YES
  MENU-ITEM m_cons:SENSITIVE IN MENU menu-b-add = YES.
  MENU-ITEM m_goto:SENSITIVE IN MENU menu-b-add = YES.
  MENU-ITEM m_script:SENSITIVE IN MENU menu-b-sel = YES.
END.
ELSE DO:
  MENU-ITEM m_cond:SENSITIVE IN MENU menu-b-add = NO .
  MENU-ITEM m_cons:SENSITIVE IN MENU menu-b-add = NO .
  MENU-ITEM m_goto:SENSITIVE IN MENU menu-b-add = NO .
  MENU-ITEM m_script:SENSITIVE IN MENU menu-b-sel = NO.
END.
END PROCEDURE.
