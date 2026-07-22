DEFINE TEMP-TABLE tt-ruledict-param NO-UNDO LIKE ub.ruledict-param.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-update-proc-handle as handle no-undo .
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-entry-id AS INTEGER NO-UNDO.
define input parameter p-entry-type as character no-undo .
DEFINE INPUT PARAMETER p-language AS character NO-UNDO.
DEFINE INPUT PARAMETER p-param-num AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка ruledict-param".
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
DEFINE BUFFER locked_ruledict-param FOR dictdb.ruledict-param.
DEFINE BUFFER last_ruledict-param FOR dictdb.ruledict-param.
DEFINE BUFFER locked_ruledict FOR ub.ruledict.
define variable v-entry-type as character no-undo .
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE cb-object-type AS CHARACTER
     LABEL "Тип Объект"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN
     SIZE 23 BY 1 NO-UNDO.
DEFINE VARIABLE rs-list AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "", "",
"LIST", "LIST",
"SORTED-LIST", "SORTED-LIST"
     SIZE 22.5 BY 1 NO-UNDO.
DEFINE VARIABLE t-container AS LOGICAL INITIAL no
     LABEL "CONTAINER"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 TOOLTIP "ХРАНИТСЯ В КОНТЕЙНЕРЕ ПРОЦЕССОВ" NO-UNDO.
DEFINE VARIABLE t-hidden AS LOGICAL INITIAL no
     LABEL "HIDDEN"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 TOOLTIP "Недоступен для задания и нигде не выводится" NO-UNDO.
DEFINE VARIABLE t-printable AS LOGICAL INITIAL no
     LABEL "PRINTABLE"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 TOOLTIP "Выводится при печати параметров в машине отчетов" NO-UNDO.
DEFINE VARIABLE t-read-only AS LOGICAL INITIAL no
     LABEL "READ-ONLY"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE t-temp AS LOGICAL INITIAL no
     LABEL "TEMP"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 TOOLTIP "Выводится при печати параметров в машине отчетов" NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-ruledict-param SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     tt-ruledict-param.entry-id AT ROW 1 COL 32 COLON-ALIGNED WIDGET-ID 2
          LABEL "ID термина"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
          FGCOLOR 4
     tt-ruledict-param.param-num AT ROW 1 COL 56 COLON-ALIGNED WIDGET-ID 38
          LABEL "№ параметра"
          VIEW-AS FILL-IN
          SIZE 12 BY 1.07
          FGCOLOR 4
     tt-ruledict-param.language AT ROW 1 COL 71 NO-LABEL WIDGET-ID 40
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "ABL", "ABL":U
          SIZE 8.5 BY 1
     b-lkp AT ROW 1 COL 80.5 WIDGET-ID 48
     B-Help AT ROW 1 COL 95
     rs-list AT ROW 2 COL 77 NO-LABEL WIDGET-ID 56
     tt-ruledict-param.param-mode AT ROW 2.87 COL 15 COLON-ALIGNED WIDGET-ID 18
          LABEL "Мода параметра" FORMAT "x(30)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 24.5 BY 1
     tt-ruledict-param.param-data-type AT ROW 2.87 COL 52 COLON-ALIGNED WIDGET-ID 20
          LABEL "Тип данных" FORMAT "X(20)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 23 BY 1
     t-read-only AT ROW 3 COL 80.5 WIDGET-ID 52
     t-hidden AT ROW 4 COL 80.5 WIDGET-ID 54
     cb-object-type AT ROW 4.2 COL 52 COLON-ALIGNED WIDGET-ID 42
     t-printable AT ROW 5 COL 80.5 WIDGET-ID 60
     tt-ruledict-param.param-name AT ROW 5.53 COL 15 COLON-ALIGNED WIDGET-ID 16
          LABEL "Имя параметра"
          VIEW-AS FILL-IN
          SIZE 60 BY 1
     t-temp AT ROW 6 COL 80.5 WIDGET-ID 62
     tt-ruledict-param.param-label AT ROW 6.87 COL 15 COLON-ALIGNED WIDGET-ID 22
          LABEL "Лейбл" FORMAT "x(255)"
          VIEW-AS FILL-IN
          SIZE 76.5 BY 1
     tt-ruledict-param.init-value-character AT ROW 8.2 COL 15 COLON-ALIGNED WIDGET-ID 24
          LABEL "Нач.знач." FORMAT "X(255)"
          VIEW-AS FILL-IN
          SIZE 76.5 BY 1
     tt-ruledict-param.init-value-date AT ROW 9.53 COL 15 COLON-ALIGNED WIDGET-ID 26
          LABEL "Нач.знач."
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     t-container AT ROW 9.53 COL 80.5 WIDGET-ID 64
     tt-ruledict-param.init-value-decimal AT ROW 10.87 COL 15 COLON-ALIGNED WIDGET-ID 28
          LABEL "Нач.знач."
          VIEW-AS FILL-IN
          SIZE 28.5 BY 1
     tt-ruledict-param.init-value-integer AT ROW 12.2 COL 15 COLON-ALIGNED WIDGET-ID 30
          LABEL "Нач.знач."
          VIEW-AS FILL-IN
          SIZE 28.5 BY 1
     tt-ruledict-param.init-value-logical AT ROW 13.53 COL 17 WIDGET-ID 34
          LABEL "Нач.знач."
          VIEW-AS TOGGLE-BOX
          SIZE 23.5 BY .8
     tt-ruledict-param.documentation AT ROW 15.13 COL 1 NO-LABEL WIDGET-ID 12
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 7.63
     "Описание" VIEW-AS TEXT
          SIZE 14.5 BY .77 AT ROW 14.07 COL 1.5 WIDGET-ID 14
     SPACE(83.50) SKIP(8.40)
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
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
define variable v-longchar as longchar no-undo .
define variable v-ok as logical no-undo .
DEFINE BUFFER buf_clob-data FOR ub.clob-data.
DEFINE BUFFER buf_clob-bind FOR ub.clob-bind.
FOR first buf_clob-data NO-LOCK where
         buf_clob-data.db-num = 0
  AND buf_clob-data.file-name = tt-ruledict-param.init-value-character
 ,
FIRST  buf_clob-bind NO-LOCK where
   buf_clob-bind.resource-type = 'gate':U
AND buf_clob-bind.db-num = buf_clob-data.db-num
AND buf_clob-data.int64-id = buf_clob-bind.int64-id:
    LEAVE .
END.
v-longchar = buf_clob-data.cdata.
run gbl/d-longchar.w (
                       input ?
                      ,input (
                                'title=':u + "XSD-схема" + '\':u
                              + 'Editor_row=2\':u
                              + 'Editor_col=1\':u
                              + 'Editor_width=96\':u
                              + 'Editor_height=15\':u
                              + 'readonly=yes\':u)
                      ,input-output v-longchar
                      ,output v-ok ) no-error .
assign
v-longchar = '':U.
END.
ON VALUE-CHANGED OF tt-ruledict-param.param-data-type IN FRAME Dialog-Frame
DO:
  ASSIGN
  tt-ruledict-param.param-data-type.
  RUN switch-data-type IN THIS-PROCEDURE .
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
if valid-handle(p-update-proc-handle) then do:
  run fill-ruledict-param in p-update-proc-handle ( input buffer tt-ruledict-param:handle
                                                   ,input p-mode
                                                   ) no-error.
  if error-status:error then do:
    MESSAGE
    substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    VIEW-AS ALERT-BOX ERROR.
    undo main-block, return error.
  end.
 v-entry-type = p-entry-type.
end.
else do:
  IF p-entry-id = 0 THEN DO:
    MESSAGE "Не задан ID термина в словаре"
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
end.
IF p-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
  FIND FIRST locked_ruledict EXCLUSIVE-LOCK WHERE
          LOCKED_ruledict.entry-id = p-entry-id .
  CREATE tt-ruledict-param.
  FIND LAST LAST_ruledict-param NO-LOCK WHERE
          last_ruledict-param.entry-id = p-entry-id
        NO-ERROR.
  ASSIGN
  tt-ruledict-param.param-num = (IF AVAILABLE LAST_ruledict-param
                                THEN LAST_ruledict-param.param-num + 1
                                ELSE 1)
  tt-ruledict-param.entry-id = p-entry-id
  .
END.
else do:
  IF p-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
      FIND FIRST locked_ruledict EXCLUSIVE-LOCK WHERE
              LOCKED_ruledict.entry-id = p-entry-id .
      FIND FIRST locked_ruledict-param EXCLUSIVE-LOCK WHERE
              LOCKED_ruledict-param.entry-id = p-entry-id
          AND LOCKED_ruledict-param.LANGUAGE = p-language
          AND LOCKED_ruledict-param.param-num = p-param-num.
  END.
  IF p-mode = 'ПРОСМОТР':U THEN DO:
      FIND FIRST locked_ruledict no-lock WHERE
              LOCKED_ruledict.entry-id = p-entry-id
          .
      FIND FIRST locked_ruledict-param no-LOCK WHERE
              LOCKED_ruledict-param.entry-id = p-entry-id
          AND LOCKED_ruledict-param.LANGUAGE = p-language
          AND LOCKED_ruledict-param.param-num = p-param-num.
  END.
end.
if not valid-handle(p-update-proc-handle) then do:
  create tt-ruledict-param.
  buffer-copy locked_ruledict-param to tt-ruledict-param.
  v-entry-type = locked_ruledict.entry-type.
end.
RUN Myenable in this-procedure .
WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-ruledict-param SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY rs-list t-read-only t-hidden cb-object-type t-printable t-temp
          t-container
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-ruledict-param THEN
    DISPLAY tt-ruledict-param.entry-id tt-ruledict-param.param-num
          tt-ruledict-param.language tt-ruledict-param.param-mode
          tt-ruledict-param.param-data-type tt-ruledict-param.param-name
          tt-ruledict-param.param-label tt-ruledict-param.init-value-character
          tt-ruledict-param.init-value-date tt-ruledict-param.init-value-decimal
          tt-ruledict-param.init-value-integer
          tt-ruledict-param.init-value-logical tt-ruledict-param.documentation
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit tt-ruledict-param.entry-id tt-ruledict-param.param-num
         tt-ruledict-param.language b-lkp B-Help rs-list
         tt-ruledict-param.param-mode tt-ruledict-param.param-data-type
         t-read-only t-hidden cb-object-type t-printable
         tt-ruledict-param.param-name t-temp tt-ruledict-param.param-label
         tt-ruledict-param.init-value-character
         tt-ruledict-param.init-value-date t-container
         tt-ruledict-param.init-value-decimal
         tt-ruledict-param.init-value-integer
         tt-ruledict-param.init-value-logical tt-ruledict-param.documentation
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
ASSIGN
frame Dialog-Frame :title = substitute("Параметр &1 термина &2 тип термина &3", tt-ruledict-param.param-num, locked_ruledict.script-al, locked_ruledict.entry-type)
tt-ruledict-param.param-data-type:LIST-ITEMS IN FRAME Dialog-Frame = 'character,date,decimal,integer,logical':U + chr(44) + 'longchar':U
tt-ruledict-param.param-mode:LIST-ITEMS IN FRAME Dialog-Frame = 'input,output,input-output,buffer,input table,output table,input-output table':u
cb-object-type:LIST-ITEMS IN FRAME Dialog-Frame = chr(44) + 'r-b':U +
                                                   chr(44) + 'period-type':U +
                                                   chr(44) + 'output-type':U +
                                                   chr(44) + 'dis-rule':U +
                                                   chr(44) + 'prop-ref':U +
                                                   chr(44) + 'clients':U +
                                                   chr(44) + 'clients':U + "_null" +
                                                   chr(44) + 'sysconf':U +
                                                   chr(44) + 'cli-grp':U +
                                                   chr(44) + 'shop':U +
                                                   chr(44) + 'ext-system':U +
                                                   chr(44) + 'gds-discnt-role,subtotal-discnt-role,pay-discnt-role':U +
                                                   chr(44) + 'goods':U + "_null" +
                                                   chr(44) + 'discnt-v-type-manual':U +
                                                   chr(44) + 'cash-pay':U + "_null" +
                                                   chr(44) + 'dis-card':U + "_null" +
                                                   chr(44) + 'chk-doc':U + "_wth-type_null" +
                                                   chr(44) + 'chk-doc':U + "_wth-type" +
                                                   chr(44) + "xsd" +
                                                   chr(44) + "sub-type" +
                                                   chr(44) + "output-type" +
                                                   chr(44) + "dataset" +
                                                   chr(44) + "id"
cb-object-type = tt-ruledict-param.param-2-data-type
rs-list = (if lookup("LIST", tt-ruledict-param.param-3-data-type) > 0 then "LIST" else rs-list)
rs-list = (if lookup("SORTED-LIST", tt-ruledict-param.param-3-data-type) > 0 then "SORTED-LIST" else rs-list)
t-READ-ONLY = lookup("READ-ONLY", tt-ruledict-param.param-3-data-type) > 0
t-hidden = lookup("hidden", tt-ruledict-param.param-3-data-type) > 0
t-printable = lookup("printable", tt-ruledict-param.param-3-data-type) > 0
t-temp = lookup("temp", tt-ruledict-param.param-3-data-type) > 0
t-container = lookup("container", tt-ruledict-param.param-3-data-type) > 0
.
IF AVAILABLE tt-ruledict-param THEN
DISPLAY
tt-ruledict-param.entry-id
tt-ruledict-param.param-mode
tt-ruledict-param.param-data-type
tt-ruledict-param.LANGUAGE
tt-ruledict-param.param-num
tt-ruledict-param.param-name
tt-ruledict-param.param-label
tt-ruledict-param.init-value-character WHEN tt-ruledict-param.param-data-type = 'character':U
tt-ruledict-param.init-value-date WHEN tt-ruledict-param.param-data-type = 'date':U
tt-ruledict-param.init-value-decimal WHEN tt-ruledict-param.param-data-type = 'decimal':U
tt-ruledict-param.init-value-integer WHEN tt-ruledict-param.param-data-type = 'integer':U
tt-ruledict-param.init-value-logical WHEN tt-ruledict-param.param-data-type = 'logical':U
tt-ruledict-param.documentation
cb-object-type
rs-list
t-read-only
t-hidden
t-printable
t-temp
t-container
WITH FRAME Dialog-Frame .
ENABLE
B-exit  when p-mode <> 'ПРОСМОТР':U
b-quit
B-Help
tt-ruledict-param.param-mode when p-mode <> 'ПРОСМОТР':U
tt-ruledict-param.param-data-type when p-mode <> 'ПРОСМОТР':U
tt-ruledict-param.param-name       when p-mode <> 'ПРОСМОТР':U
tt-ruledict-param.param-label when p-mode <> 'ПРОСМОТР':U
tt-ruledict-param.documentation
cb-object-type when p-mode <> 'ПРОСМОТР':U
rs-list when p-mode <> 'ПРОСМОТР':U
t-read-only when p-mode <> 'ПРОСМОТР':U
t-hidden when p-mode <> 'ПРОСМОТР':U
t-printable when p-mode <> 'ПРОСМОТР':U
t-temp when p-mode <> 'ПРОСМОТР':U
t-container when p-mode <> 'ПРОСМОТР':U
b-lkp WHEN p-mode = 'ПРОСМОТР':U AND tt-ruledict-param.param-2-data-type = "xsd"
WITH FRAME Dialog-Frame .
IF NOT (v-entry-type = 'prop-script':U
        or
        v-entry-type = 'rule':U
        or
        v-entry-type = 'rule-profile':U
        )
        THEN DO:
 HIDE
 cb-object-type
 IN FRAME Dialog-Frame.
END.
else do:
end.
if p-mode = 'ПРОСМОТР':U then do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  tt-ruledict-param.documentation :read-only in frame Dialog-Frame = yes
  .
  hide b-exit in frame Dialog-Frame .
end.
VIEW FRAME Dialog-Frame .
RUN switch-data-type IN THIS-PROCEDURE .
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS recID  NO-UNDO.
define variable v-param-3-data-type as character no-undo.
IF p-mode = 'ПРОСМОТР':U THEN DO:
    RETURN.
END.
ASSIGN
FRAME Dialog-Frame
tt-ruledict-param.entry-id
tt-ruledict-param.LANGUAGE
tt-ruledict-param.param-mode
tt-ruledict-param.param-num
tt-ruledict-param.param-name
tt-ruledict-param.param-label
cb-object-type
rs-list
t-read-only
t-hidden
t-printable
t-temp
t-container
tt-ruledict-param.param-data-type
tt-ruledict-param.param-2-data-type = (if cb-object-type <> ? then cb-object-type else '')
v-param-3-data-type = (if rs-list = "" then "" else  rs-list)
v-param-3-data-type = v-param-3-data-type +
                      (if v-param-3-data-type = "" then "" else chr(44)) +
                      (if t-read-only then "READ-ONLY" else "")
v-param-3-data-type = v-param-3-data-type +
                      (if v-param-3-data-type = "" then "" else chr(44)) +
                      (if t-hidden then "HIDDEN" else "")
 v-param-3-data-type = v-param-3-data-type +
                          (if v-param-3-data-type = "" then "" else chr(44)) +
                          (if t-printable then "PRINTABLE" else "")
 v-param-3-data-type = v-param-3-data-type +
                          (if v-param-3-data-type = "" then "" else chr(44)) +
                          (if t-temp then "TEMP" else "")
v-param-3-data-type = v-param-3-data-type +
                          (if v-param-3-data-type = "" then "" else chr(44)) +
                          (if t-container then "CONTAINER" else "")
v-param-3-data-type = replace(v-param-3-data-type, chr(44) + chr(44), chr(44))
v-param-3-data-type = trim(v-param-3-data-type, chr(44))
tt-ruledict-param.param-3-data-type = v-param-3-data-type
tt-ruledict-param.documentation
.
if tt-ruledict-param.init-value-character:visible in frame Dialog-Frame then do:
  assign
  tt-ruledict-param.init-value-character
  tt-ruledict-param.init-value-date       = ?
  tt-ruledict-param.init-value-decimal    = 0.0
  tt-ruledict-param.init-value-integer    = 0
  tt-ruledict-param.init-value-logical    = no
  .
end.
if tt-ruledict-param.init-value-date:visible in frame Dialog-Frame then do:
  assign
  tt-ruledict-param.init-value-character  = '':U
  tt-ruledict-param.init-value-date
  tt-ruledict-param.init-value-decimal    = 0.0
  tt-ruledict-param.init-value-integer    = 0
  tt-ruledict-param.init-value-logical    = no
  .
end.
if tt-ruledict-param.init-value-decimal:visible in frame Dialog-Frame then do:
  assign
  tt-ruledict-param.init-value-character  = '':U
  tt-ruledict-param.init-value-date       = ?
  tt-ruledict-param.init-value-decimal
  tt-ruledict-param.init-value-integer    = 0
  tt-ruledict-param.init-value-logical    = no
  .
end.
if tt-ruledict-param.init-value-integer:visible in frame Dialog-Frame then do:
  assign
  tt-ruledict-param.init-value-character  = '':U
  tt-ruledict-param.init-value-date       = ?
  tt-ruledict-param.init-value-decimal    = 0.0
  tt-ruledict-param.init-value-integer
  tt-ruledict-param.init-value-logical    = no
  .
end.
if tt-ruledict-param.init-value-logical:visible in frame Dialog-Frame then do:
  assign
  tt-ruledict-param.init-value-character  = '':U
  tt-ruledict-param.init-value-date       = ?
  tt-ruledict-param.init-value-decimal    = 0.0
  tt-ruledict-param.init-value-integer    = 0
  tt-ruledict-param.init-value-logical
  .
end.
v-rec = p-rec.
if valid-handle(p-update-proc-handle) then do:
  run save-ruledict-param in p-update-proc-handle ( input buffer tt-ruledict-param:handle
                                                   ,input p-mode
                                                   ,output v-rec
                                                  ) no-error.
end.
else do:
  run rul/ruledict-param1.p ( INPUT p-mode
                  ,INPUT NO
                  ,INPUT-OUTPUT v-rec
                  ,INPUT tt-ruledict-param.entry-id
                  ,INPUT tt-ruledict-param.LANGUAGE
                  ,INPUT tt-ruledict-param.param-num
                  ,INPUT tt-ruledict-param.param-name
                  ,INPUT tt-ruledict-param.param-label
                  ,INPUT tt-ruledict-param.param-data-type
                  ,INPUT tt-ruledict-param.param-2-data-type
                  ,INPUT tt-ruledict-param.param-3-data-type
                  ,INPUT tt-ruledict-param.param-mode
                  ,INPUT tt-ruledict-param.documentation
                  ,INPUT tt-ruledict-param.init-value-character
                  ,INPUT tt-ruledict-param.init-value-date
                  ,INPUT tt-ruledict-param.init-value-decimal
                  ,INPUT tt-ruledict-param.init-value-integer
                  ,INPUT tt-ruledict-param.init-value-logical
                ) no-error.
end.
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
PROCEDURE switch-data-type :
HIDE
tt-ruledict-param.init-value-character  IN FRAME Dialog-Frame
tt-ruledict-param.init-value-date
tt-ruledict-param.init-value-decimal
tt-ruledict-param.init-value-integer
tt-ruledict-param.init-value-logical
.
DISABLE
tt-ruledict-param.init-value-character
tt-ruledict-param.init-value-date
tt-ruledict-param.init-value-decimal
tt-ruledict-param.init-value-integer
tt-ruledict-param.init-value-logical
with FRAME Dialog-Frame.
CASE tt-ruledict-param.param-data-type:
  WHEN 'character':U
  THEN DO:
     DISPLAY
     tt-ruledict-param.init-value-character
     WITH FRAME Dialog-Frame.
     ENABLE
     tt-ruledict-param.init-value-character WHEN p-mode <> 'ПРОСМОТР':U
     WITH FRAME Dialog-Frame.
  END.
  WHEN 'longchar':U then do:
     DISPLAY
     tt-ruledict-param.init-value-character
     WITH FRAME Dialog-Frame.
     ENABLE
     tt-ruledict-param.init-value-character  WHEN p-mode <> 'ПРОСМОТР':U
     WITH FRAME Dialog-Frame.
  end.
  WHEN 'date':U THEN DO:
     DISPLAY
     tt-ruledict-param.init-value-date
     WITH FRAME Dialog-Frame.
     ENABLE
     tt-ruledict-param.init-value-date WHEN p-mode <> 'ПРОСМОТР':U
     WITH FRAME Dialog-Frame.
  END.
  WHEN 'decimal':U THEN DO:
     DISPLAY
     tt-ruledict-param.init-value-decimal
     WITH FRAME Dialog-Frame.
     ENABLE
     tt-ruledict-param.init-value-decimal WHEN p-mode <> 'ПРОСМОТР':U
     WITH FRAME Dialog-Frame.
  END.
  WHEN 'integer':U THEN DO:
     DISPLAY
     tt-ruledict-param.init-value-integer
     WITH FRAME Dialog-Frame.
     ENABLE
     tt-ruledict-param.init-value-integer WHEN p-mode <> 'ПРОСМОТР':U
     WITH FRAME Dialog-Frame.
  END.
  WHEN 'logical':U THEN DO:
     DISPLAY
     tt-ruledict-param.init-value-logical
     WITH FRAME Dialog-Frame.
     ENABLE
     tt-ruledict-param.init-value-logical WHEN p-mode <> 'ПРОСМОТР':U
     WITH FRAME Dialog-Frame.
  END.
END CASE.
END PROCEDURE.
