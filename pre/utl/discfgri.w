DEFINE BUFFER locked_dis-cfg-rule FOR ub.dis-cfg-rule.
DEFINE BUFFER locked_dis-rule FOR ub.dis-rule.
DEFINE BUFFER Locked_dis-time-rule FOR ub.dis-time-rule.
DEFINE TEMP-TABLE tt-dis-cfg-rule NO-UNDO LIKE ub.dis-cfg-rule.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-table-name AS character NO-UNDO.
DEFINE INPUT PARAMETER p-pos-type AS character NO-UNDO.
DEFINE INPUT PARAMETER p-templ-rl-root AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-time-templ-rl-root AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-discnt-role AS character NO-UNDO.
DEFINE INPUT PARAMETER p-self-nonunique AS character NO-UNDO.
DEFINE OUTPUT PARAMETER p-rec AS RECID NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка конфигурации ПРАВИЛО-СКИДКИ-POS-РАСПИСАНИЕ".
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
define variable v-is-copy as logical no-undo .
DEFINE VARIABLE v-self-nonunique-grp-list-items AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
DEFINE BUFFER buf_dis-time-rule FOR ub.dis-time-rule.
DEFINE BUTTON b-dis-ruls
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 4 BY 1.
DEFINE BUTTON b-dist-rls
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 4 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE cb-discnt-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип Скидки"
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 55 BY .93 NO-UNDO.
DEFINE VARIABLE cb-subject-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Воздействие (место расчета)"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 55.5 BY .93 NO-UNDO.
DEFINE VARIABLE f-dis-rule-des AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 83.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-dis-time-rule-des AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 83.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE tg-has-global AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY .83 NO-UNDO.
DEFINE VARIABLE tg-has-host AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY .83 NO-UNDO.
DEFINE VARIABLE tg-has-object AS LOGICAL INITIAL no
     LABEL "Toggle 3"
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY .83 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      locked_dis-cfg-rule,
      tt-dis-cfg-rule SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     tt-dis-cfg-rule.templ-rl-root AT ROW 3 COL 5 COLON-ALIGNED NO-LABEL WIDGET-ID 16
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     f-dis-rule-des AT ROW 3 COL 16 NO-LABEL WIDGET-ID 4
     b-dis-ruls AT ROW 3.13 COL 2 WIDGET-ID 2
     b-dist-rls AT ROW 5 COL 2 WIDGET-ID 6
     tt-dis-cfg-rule.time-templ-rl-root AT ROW 5 COL 5 COLON-ALIGNED NO-LABEL WIDGET-ID 18
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     f-dis-time-rule-des AT ROW 5 COL 16 NO-LABEL WIDGET-ID 8
     tt-dis-cfg-rule.pos-type AT ROW 6.33 COL 28 COLON-ALIGNED WIDGET-ID 38
          LABEL "Место использ."
          VIEW-AS COMBO-BOX INNER-LINES 15
          LIST-ITEM-PAIRS "Item 1","Item 1"
          DROP-DOWN-LIST
          SIZE 23 BY 1
     tt-dis-cfg-rule.table-name AT ROW 6.33 COL 67 COLON-ALIGNED WIDGET-ID 40
          LABEL "Таблица связи" FORMAT "x(40)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Item 1","Item 1"
          DROP-DOWN-LIST
          SIZE 30.5 BY 1
     tt-dis-cfg-rule.self-nonunique AT ROW 7.4 COL 67 COLON-ALIGNED WIDGET-ID 58
          LABEL "self-nonunique"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Item 1","Item 1"
          DROP-DOWN-LIST
          SIZE 30 BY 1
     tt-dis-cfg-rule.discnt-role AT ROW 9.53 COL 28 COLON-ALIGNED WIDGET-ID 42
          LABEL "Роль скидки" FORMAT "X(40)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Item 1","Item 1"
          DROP-DOWN-LIST
          SIZE 51 BY 1
     tt-dis-cfg-rule.nonunique AT ROW 10.87 COL 28 COLON-ALIGNED WIDGET-ID 36
          LABEL "nonunique"
          VIEW-AS FILL-IN NATIVE
          SIZE 32.5 BY 1.07
     tt-dis-cfg-rule.link-prop AT ROW 13.8 COL 54 COLON-ALIGNED WIDGET-ID 64
          LABEL "Св-ва связи с объектом"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Item 1",0
          DROP-DOWN-LIST
          SIZE 34.5 BY 1
     tg-has-global AT ROW 14 COL 21 WIDGET-ID 46
     tg-has-host AT ROW 15 COL 21 WIDGET-ID 48
     tt-dis-cfg-rule.projection AT ROW 15.93 COL 38.5 COLON-ALIGNED HELP
          "" WIDGET-ID 66
          LABEL "Проекция"
          VIEW-AS FILL-IN
          SIZE 55.5 BY 1 TOOLTIP "Проекцич полей первичн.ключа (через запятую)"
     tg-has-object AT ROW 16 COL 21 WIDGET-ID 50
     cb-discnt-type AT ROW 18.07 COL 39 COLON-ALIGNED WIDGET-ID 68
     cb-subject-type AT ROW 20.2 COL 39 COLON-ALIGNED WIDGET-ID 70
     "Бывает фирма:" VIEW-AS TEXT
          SIZE 13.5 BY .67 AT ROW 15 COL 6 WIDGET-ID 54
     "Бывает объект:" VIEW-AS TEXT
          SIZE 14.5 BY .67 AT ROW 16 COL 4.9 WIDGET-ID 56
     "Шаблон расписания" VIEW-AS TEXT
          SIZE 21 BY 1 AT ROW 4 COL 4 WIDGET-ID 22
     "Шаблон правила скидок" VIEW-AS TEXT
          SIZE 21 BY 1 AT ROW 2 COL 4 WIDGET-ID 20
     "Бывает глобальной:" VIEW-AS TEXT
          SIZE 18.5 BY .67 AT ROW 14 COL 1 WIDGET-ID 52
     SPACE(80.20) SKIP(8.55)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Запись конфигурации правил скидок"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       f-dis-rule-des:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-dis-time-rule-des:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-dis-ruls IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-sts AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
run utl/disruls0.w (
                    input parparentproc
                    ,input "b-sel":U
                    ,input-output v-rid-list ) no-error .
IF v-rid-list <> '':U THEN DO:
  FIND FIRST buf_dis-rule NO-LOCK WHERE recid(buf_dis-rule) = INTEGER(v-rid-list) NO-ERROR.
  IF NOT AVAILABLE buf_dis-rule THEN RETURN NO-APPLY.
  ASSIGN
  tt-dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
  f-dis-rule-des = buf_dis-rule.des
  .
END.
ELSE DO:
  ASSIGN
  tt-dis-cfg-rule.templ-rl-root = 0
  f-dis-rule-des = '':U
  .
END.
DISPLAY
f-dis-rule-des
tt-dis-cfg-rule.templ-rl-root
WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF b-dist-rls IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-sts AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_dis-time-rule FOR ub.dis-time-rule.
    run ref/dist-rls.w (
                   input parparentproc
                  ,input "b-sel"
                  ,input "template"
                  ,input 0
                  ,input 0
                  ,input ''
                  ,input-output v-sts
                  ,input-output v-rid-list) no-error .
IF v-rid-list <> '':U THEN DO:
  FIND FIRST buf_dis-time-rule NO-LOCK WHERE recid(buf_dis-time-rule) = INTEGER(v-rid-list) NO-ERROR.
  IF NOT AVAILABLE buf_dis-time-rule THEN RETURN NO-APPLY.
  ASSIGN
  tt-dis-cfg-rule.time-templ-rl-root = buf_dis-time-rule.templ-rl-root
  f-dis-time-rule-des = buf_dis-time-rule.des
  .
END.
ELSE DO:
  ASSIGN
  tt-dis-cfg-rule.time-templ-rl-root = 0
  f-dis-time-rule-des = '':U
  .
END.
DISPLAY
f-dis-time-rule-des
tt-dis-cfg-rule.time-templ-rl-root
WITH FRAME Dialog-Frame.
END.
ON VALUE-CHANGED OF tt-dis-cfg-rule.table-name IN FRAME Dialog-Frame
DO:
  ASSIGN
  tt-dis-cfg-rule.table-name.
  RUN refresh-discnt-role IN this-procedure .
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
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  IF p-mode <> 'ДОБАВЛЕНИЕ':U
  AND p-mode <> 'ИЗМЕНЕНИЕ':U
  AND p-mode <> 'ПРОСМОТР':U
  AND p-mode <> 'КОПИРОВАНИЕ':U
  THEN DO:
    MESSAGE
    "Неверное значение параметра p-mode=" p-mode
     VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
  CASE p-mode:
    WHEN 'ДОБАВЛЕНИЕ':U THEN DO:
      CREATE tt-dis-cfg-rule.
    END.
    WHEN 'ИЗМЕНЕНИЕ':U THEN DO:
       FIND FIRST LOCKED_dis-cfg-rule EXCLUSIVE-LOCK where
               LOCKED_dis-cfg-rule.TABLE-name = p-table-name
           AND LOCKED_dis-cfg-rule.pos-type = p-pos-type
           AND LOCKED_dis-cfg-rule.templ-rl-root = p-templ-rl-root
           AND LOCKED_dis-cfg-rule.time-templ-rl-root = p-time-templ-rl-root
           AND LOCKED_dis-cfg-rule.discnt-role = p-discnt-role
           AND LOCKED_dis-cfg-rule.self-nonunique = p-self-nonunique.
      CREATE tt-dis-cfg-rule.
      BUFFER-COPY LOCKED_dis-cfg-rule TO tt-dis-cfg-rule.
    END.
    WHEN 'ПРОСМОТР':U
    or when 'КОПИРОВАНИЕ':U
    THEN DO:
        FIND FIRST LOCKED_dis-cfg-rule no-lock where
                LOCKED_dis-cfg-rule.TABLE-name = p-table-name
            AND LOCKED_dis-cfg-rule.pos-type = p-pos-type
            AND LOCKED_dis-cfg-rule.templ-rl-root = p-templ-rl-root
            AND LOCKED_dis-cfg-rule.time-templ-rl-root = p-time-templ-rl-root
            AND LOCKED_dis-cfg-rule.discnt-role = p-discnt-role
            AND LOCKED_dis-cfg-rule.self-nonunique = p-self-nonunique.
      CREATE tt-dis-cfg-rule.
      BUFFER-COPY LOCKED_dis-cfg-rule TO tt-dis-cfg-rule.
    END.
  END CASE.
  if p-mode = 'КОПИРОВАНИЕ':U then do:
    assign
    v-is-copy = yes
    p-mode = 'ДОБАВЛЕНИЕ':U
    .
  end.
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH locked_dis-cfg-rule SHARE-LOCK,       EACH tt-dis-cfg-rule WHERE TRUE  SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY f-dis-rule-des f-dis-time-rule-des tg-has-global tg-has-host
          tg-has-object cb-discnt-type cb-subject-type
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-dis-cfg-rule THEN
    DISPLAY tt-dis-cfg-rule.templ-rl-root tt-dis-cfg-rule.time-templ-rl-root
          tt-dis-cfg-rule.pos-type tt-dis-cfg-rule.table-name
          tt-dis-cfg-rule.self-nonunique tt-dis-cfg-rule.discnt-role
          tt-dis-cfg-rule.nonunique tt-dis-cfg-rule.link-prop
          tt-dis-cfg-rule.projection
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help tt-dis-cfg-rule.templ-rl-root f-dis-rule-des
         b-dis-ruls b-dist-rls tt-dis-cfg-rule.time-templ-rl-root
         f-dis-time-rule-des tt-dis-cfg-rule.pos-type
         tt-dis-cfg-rule.table-name tt-dis-cfg-rule.self-nonunique
         tt-dis-cfg-rule.discnt-role tt-dis-cfg-rule.nonunique
         tt-dis-cfg-rule.link-prop tg-has-global tg-has-host
         tt-dis-cfg-rule.projection tg-has-object cb-discnt-type
         cb-subject-type
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii         AS INTEGER   NO-UNDO.
v-list-items = "":U + chr(44) + "":U.
DO v-ii = 1 TO NUM-ENTRIES('sum-grp,cli-grp':u):
    ASSIGN
    v-list-items = v-list-items +  chr(44) +
                   ENTRY(v-ii, 'Группы товаров (на кассе),Группа клиентов':u) + chr(44) +
                   ENTRY(v-ii, 'sum-grp,cli-grp':u).
END.
ASSIGN
v-self-nonunique-grp-list-items = v-list-items.
v-list-items = "":U + chr(44) + "":U.
DO v-ii = 1 TO NUM-ENTRIES('IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,MARIA,-,bo':U):
    ASSIGN
    v-list-items = v-list-items +  chr(44) +
                   ENTRY(v-ii, 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,MARIA,Накладная,Бэкофис':U) + chr(44) +
                   ENTRY(v-ii, 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,MARIA,-,bo':U).
END.
assign
tt-dis-cfg-rule.pos-type:list-item-pairs in frame Dialog-Frame = v-list-items.
v-list-items = "":U + chr(44) + "":U.
DO v-ii = 1 TO NUM-ENTRIES('0,1,2,3,-2,-1':U):
    ASSIGN
    v-list-items = v-list-items +  chr(44) +
                   ENTRY(v-ii, 'Объект<=>правило,->Условие правила,Объект<=>Ветка правила,Объект<=>Ссылка на правило,Объект<=>Свойство<=>правило,Объект<=>Нет правила':U) + chr(44) +
                   ENTRY(v-ii, '0,1,2,3,-2,-1':U).
END.
ASSIGN
tt-dis-cfg-rule.link-prop:LIST-ITEM-PAIRS IN FRAME Dialog-Frame = v-list-items.
assign
v-list-items = ''.
do v-ii = 1 to num-entries('0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,23,17,18,19,20,21,22,998,999,1001':U):
  v-list-items = v-list-items + entry(v-ii, '?,Клиент,Стандарт,Временная,Количество,Сумма,Персонал,Промо,Уценка,Счастл.час,Комплект,Сезонная,Катег,Ручная,Карта-маска,Округл. в пользу.клиента,Катег с исп шаблона,Оплата топливным купоном (Ашан),Абсолютная,Группа,Платеж,ЛНР,Округление,Оплата,Доп.условие,Другое,Погрешность':U) + chr(44) + entry(v-ii, '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,23,17,18,19,20,21,22,998,999,1001':U) + chr(44).
end.
v-list-items = trim(v-list-items, chr(44)).
assign
cb-discnt-type:list-item-pairs = v-list-items.
assign
v-list-items = ''.
do v-ii = 1 to num-entries('0,1,2,3,4,5,7,8':U):
  v-list-items = v-list-items + entry(v-ii, 'Неизв,Товар,Подитог,Итог,Чек,Оплата,Товар_б/итог.скидки,Группа':U) + chr(44) + entry(v-ii, '0,1,2,3,4,5,7,8':U) + chr(44).
end.
v-list-items = trim(v-list-items, chr(44)).
assign
cb-subject-type:list-item-pairs = v-list-items.
assign
tt-dis-cfg-rule.table-name:list-item-pairs in frame Dialog-Frame =
'Скидка Товара на объ.':U + chr(44) +
'dis-gds-rule':U + chr(44) +
'Общие скидки':U + chr(44) +
'dis-thbj-rule':U + chr(44) +
'Скидки на платеж':U + chr(44) +
'dis-cp-rule':U + chr(44) +
'Скидки для ДК':U + chr(44) +
'dis-dc-rule':U + chr(44) +
'Скидки на типы ДК':U + chr(44) +
'dis-dct-rule':U + chr(44) +
'Скидки по группе':U + chr(44) +
'dis-grp-rule':U
.
if available tt-dis-cfg-rule
and not (p-mode = 'ДОБАВЛЕНИЕ':U
         and
         v-is-copy = no)
then do:
  RUN refresh-discnt-role IN this-procedure .
END.
IF tt-dis-cfg-rule.templ-rl-root > 0 THEN DO:
  FIND FIRST buf_dis-rule NO-LOCK WHERE
            buf_dis-rule.rule-num = p-templ-rl-root NO-ERROR.
  IF available buf_dis-rule THEN DO:
     ASSIGN
     f-dis-rule-des = buf_dis-rule.des.
  END.
END.
IF tt-dis-cfg-rule.time-templ-rl-root > 0 THEN DO:
    FIND FIRST buf_dis-time-rule NO-LOCK WHERE
              buf_dis-time-rule.time-rule-num = p-time-templ-rl-root NO-ERROR.
    IF available buf_dis-time-rule THEN DO:
       ASSIGN
       f-dis-time-rule-des = buf_dis-time-rule.des.
    END.
END.
DISPLAY f-dis-rule-des f-dis-time-rule-des
WITH FRAME Dialog-Frame.
IF AVAILABLE tt-dis-cfg-rule THEN DO:
    assign
        tg-has-global   = ( tt-dis-cfg-rule.has-global <> 0 )
        tg-has-host     = ( tt-dis-cfg-rule.has-host   <> 0 )
        tg-has-object   = ( tt-dis-cfg-rule.has-obj    <> 0 )
        cb-discnt-type = string(tt-dis-cfg-rule.discnt-type)
        cb-subject-type = string(tt-dis-cfg-rule.subject-type)
    .
    DISPLAY
        tt-dis-cfg-rule.templ-rl-root
        tt-dis-cfg-rule.time-templ-rl-root
        tt-dis-cfg-rule.pos-type
        tt-dis-cfg-rule.table-name
        tt-dis-cfg-rule.discnt-role
        tt-dis-cfg-rule.nonunique
        tt-dis-cfg-rule.link-prop
        tg-has-global
        tg-has-host
        tg-has-object
        tt-dis-cfg-rule.projection
        cb-discnt-type
        cb-subject-type
    WITH FRAME Dialog-Frame.
END.
ENABLE
B-exit when p-mode <> 'ПРОСМОТР':U
b-quit
B-Help
b-dis-ruls when p-mode = 'ДОБАВЛЕНИЕ':U
b-dist-rls when p-mode = 'ДОБАВЛЕНИЕ':U
tt-dis-cfg-rule.pos-type  when p-mode = 'ДОБАВЛЕНИЕ':U
tt-dis-cfg-rule.table-name  when p-mode = 'ДОБАВЛЕНИЕ':U
tt-dis-cfg-rule.discnt-role when p-mode <> 'ПРОСМОТР':U
tt-dis-cfg-rule.nonunique   when p-mode <> 'ПРОСМОТР':U
tt-dis-cfg-rule.link-prop  when p-mode <> 'ПРОСМОТР':U
tt-dis-cfg-rule.projection when p-mode <> 'ПРОСМОТР':U
tg-has-global  when p-mode <> 'ПРОСМОТР':U
tg-has-host    when p-mode <> 'ПРОСМОТР':U
tg-has-object  when p-mode <> 'ПРОСМОТР':U
cb-discnt-type when p-mode <> 'ПРОСМОТР':U
cb-subject-type when p-mode <> 'ПРОСМОТР':U
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
if p-mode = 'ПРОСМОТР':U then do:
  hide
  b-exit
  in frame Dialog-Frame .
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  .
end.
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
IF p-mode = 'ПРОСМОТР':U THEN RETURN .
IF p-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
  v-rec = p-rec.
END.
ASSIGN
FRAME Dialog-Frame
tg-has-global
tg-has-host
tg-has-object
cb-discnt-type
cb-subject-type
tt-dis-cfg-rule.templ-rl-root
tt-dis-cfg-rule.time-templ-rl-root
tt-dis-cfg-rule.pos-type
tt-dis-cfg-rule.discnt-role
tt-dis-cfg-rule.has-glob = integer( tg-has-global )
tt-dis-cfg-rule.has-host = integer( tg-has-host   )
tt-dis-cfg-rule.has-obj  = integer( tg-has-object )
tt-dis-cfg-rule.table-name
tt-dis-cfg-rule.nonunique
tt-dis-cfg-rule.link-prop
tt-dis-cfg-rule.projection
tt-dis-cfg-rule.discnt-type = integer(cb-discnt-type)
tt-dis-cfg-rule.subject-type = integer(cb-subject-type)
.
IF  tt-dis-cfg-rule.self-nonunique:VISIBLE IN FRAME Dialog-Frame THEN DO:
   ASSIGN tt-dis-cfg-rule.self-nonunique.
END.
ELSE DO:
   ASSIGN tt-dis-cfg-rule.self-nonunique = '':U.
END.
run utl/discfgr1.p ( INPUT p-mode
                    ,INPUT NO
                    ,INPUT-output v-rec
                    ,INPUT tt-dis-cfg-rule.table-name
                    ,INPUT tt-dis-cfg-rule.pos-type
                    ,INPUT tt-dis-cfg-rule.templ-rl-root
                    ,INPUT tt-dis-cfg-rule.discnt-role
                    ,INPUT tt-dis-cfg-rule.time-templ-rl-root
                    ,INPUT tt-dis-cfg-rule.self-nonunique
                    ,INPUT tt-dis-cfg-rule.nonunique
                    ,INPUT tt-dis-cfg-rule.has-glob
                    ,INPUT tt-dis-cfg-rule.has-host
                    ,INPUT tt-dis-cfg-rule.has-obj
                    ,INPUT tt-dis-cfg-rule.link-prop
                    ,input tt-dis-cfg-rule.projection
                    ,input tt-dis-cfg-rule.discnt-type
                    ,input tt-dis-cfg-rule.subject-type
                    ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
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
END.
p-rec = v-rec.
END PROCEDURE.
PROCEDURE refresh-discnt-role :
define variable v-discnt-role-list as character no-undo .
define variable v-discnt-role-list-full as character no-undo .
DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii         AS INTEGER   NO-UNDO.
CASE tt-dis-cfg-rule.table-name:
    when 'dis-gds-rule':U then do:
       assign
       v-discnt-role-list = 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u
       v-discnt-role-list-full = 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u
       .
       hide
       tt-dis-cfg-rule.self-nonunique
       in FRAME Dialog-Frame.
    end.
    when 'dis-cp-rule':U then do:
       assign
       v-discnt-role-list = 'simple-pay,qnty-pay':u
       v-discnt-role-list-full = 'Скидка при оплате,Скидка на количество при оплате':u
       .
       hide
       tt-dis-cfg-rule.self-nonunique
       in FRAME Dialog-Frame.
    end.
    when 'dis-dc-rule':U then do:
       assign
       v-discnt-role-list = 'debet-pay-pcnt-disc,debet-pay-abs-disc,debet-pay-qnty-disc,debet-pay-sum-disc,debet-pay-free-disc,dc-d-pcnt,dc-cash-d-pcnt,credit-pay-pcnt-disc,credit-pay-abs-disc,credit-pay-qnty-disc,credit-pay-sum-disc,credit-pay-free-disc':u
       v-discnt-role-list-full = '% Скидка при оплате топлива по дебет.ведомости,ABS Скидка при оплате топлива по дебет.ведомости,Скидка на кол-во при оплате топлива по дебет.ведомости,Скидка на сумму при оплате топлива по дебет.ведомости,Своб скидка при оплате топлива по дебет.ведомости,% скидка на товар по ДК,% скидка на итог чека по ДК,% Скидка при оплате топлива по кредит.ведомости,Abs Скидка при оплате топлива по кредит.ведомости,Скидка на кол-во при оплате топлива по кредит.ведомости,Скидка на сумму при оплате топлива по кредит.ведомости,Своб Скидка на сумму при оплате топлива по кредит.ведомости':u
       .
       hide
       tt-dis-cfg-rule.self-nonunique
       in FRAME Dialog-Frame.
    end.
    when 'dis-dct-rule':U then do:
       assign
       v-discnt-role-list = 'calc-d-pcnt,calc-cash-d-pcnt,calc-categ,dis-tot-flag,def-categ,def-pcnt,def-cash-pcnt':u
       v-discnt-role-list-full = 'Расчет %скидки ДК на товар,Расчет %скидки ДК на итог,Расчет категории ДК,Участие в итогах по ДК,Категория ДК по умолчанию,% скидки ДК на товар по умолч.,% скидки ДК на итог по умолч.':u
       .
       hide
       tt-dis-cfg-rule.self-nonunique
       in FRAME Dialog-Frame.
    end.
    when 'dis-grp-rule':U then do:
       assign
       v-discnt-role-list = 'gds-grp-pcnt,gds-grp-pcnt-kat,gds-grp-abs,gds-grp-qnty,gds-grp-sum':u + chr(44) + 'cli-grp-pcnt':u
       v-discnt-role-list-full = '% скидка на группу товара,% скидка на группу товара для кат.клиентов,Abs скидка на группу товара,% Скидка на группу товара по кол-ву,% Скидка на группу товара на сумму':u + chr(44) + '% скидка на группу клиентов':u
       tt-dis-cfg-rule.self-nonunique:LIST-ITEM-PAIRS = v-self-nonunique-grp-list-items
       .
       DISPLAY
       tt-dis-cfg-rule.self-nonunique
       WITH FRAME Dialog-Frame.
       if p-mode <> 'ПРОСМОТР':U then do:
        enable
        tt-dis-cfg-rule.self-nonunique
        with frame Dialog-Frame .
      end.
    end.
    when 'dis-some-rule':U then do:
        hide
        tt-dis-cfg-rule.self-nonunique
        in FRAME Dialog-Frame.
    end.
    when 'dis-thbj-rule':U then do:
       assign
       v-discnt-role-list = 'pcnt-tot-kateg,dflt-gds-temp-disc,abs-tot-kateg,pcnt-codes,kateg-codes,free-discnt-flag,pmnt-discnt-flag,kat-gds-grp,temp-disc-pdf,pcnt-kat-pdf,bonus-tot,bonus-all':u
       v-discnt-role-list-full = '% Скидка на итог,Временная скидка на товар по умолчанию,Abs Скидка на итог,Коды % скидок,Коды категорий,Флаг своб.скидки,Флаг уст. скидки на платеж,Ск-ка на группу товаров для кат.клиентов,Временная через ТПЛ,Категорийная через ТПЛ,Начисление бонусов на сумму чека,Правило-итого бонусов по чеку':u
       .
       hide
       tt-dis-cfg-rule.self-nonunique
       in FRAME Dialog-Frame.
    end.
  END CASE.
DO v-ii = 1 TO NUM-ENTRIES(v-discnt-role-list):
    ASSIGN
    v-list-items = v-list-items +  (IF v-ii > 1 THEN chr(44) ELSE '':U) +
                   ENTRY(v-ii, v-discnt-role-list-full) + chr(44) +
                   ENTRY(v-ii, v-discnt-role-list).
END.
assign
tt-dis-cfg-rule.discnt-role:list-item-pairs in frame Dialog-Frame = v-list-items.
END PROCEDURE.
