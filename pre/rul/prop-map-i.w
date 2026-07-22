DEFINE TEMP-TABLE tt-prop-map NO-UNDO LIKE ub.prop-map.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-dtm-code AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-node-code AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка prop-map".
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
DEFINE BUFFER locked_prop-map FOR dictdb.prop-map.
DEFINE BUFFER last_prop-map FOR dictdb.prop-map.
DEFINE BUFFER locked_prop-head FOR ub.prop-head.
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
DEFINE BUTTON b-upper-code
     LABEL "Btn 1"
     SIZE 3 BY 1.07.
DEFINE VARIABLE cb-object-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип Объект"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 23 BY 1 NO-UNDO.
DEFINE VARIABLE T-C AS LOGICAL INITIAL no
     LABEL "C"
     VIEW-AS TOGGLE-BOX
     SIZE 4.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-O AS LOGICAL INITIAL no
     LABEL "O"
     VIEW-AS TOGGLE-BOX
     SIZE 4.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-R AS LOGICAL INITIAL no
     LABEL "R"
     VIEW-AS TOGGLE-BOX
     SIZE 4.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-W AS LOGICAL INITIAL no
     LABEL "W"
     VIEW-AS TOGGLE-BOX
     SIZE 4.5 BY 1 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-prop-map SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     tt-prop-map.dtm-code AT ROW 1 COL 34 COLON-ALIGNED WIDGET-ID 2
          LABEL "Код объекта"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
          FGCOLOR 4
     tt-prop-map.node-code AT ROW 1 COL 69 COLON-ALIGNED WIDGET-ID 38
          LABEL "Код свойства (узла)"
          VIEW-AS FILL-IN
          SIZE 12 BY 1.07
          FGCOLOR 4
     B-Help AT ROW 1 COL 95
     tt-prop-map.upper-node-code AT ROW 2.07 COL 18.5 COLON-ALIGNED WIDGET-ID 46
          LABEL "Код узла-родителя"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     b-upper-code AT ROW 2.07 COL 31 WIDGET-ID 50
     tt-prop-map.upper-node-name AT ROW 2.07 COL 51.5 COLON-ALIGNED WIDGET-ID 48
          LABEL "Имя узла-родителя"
          VIEW-AS FILL-IN
          SIZE 45 BY 1
     T-R AT ROW 3.25 COL 72.5 WIDGET-ID 56
     T-W AT ROW 3.25 COL 78 WIDGET-ID 58
     T-C AT ROW 3.25 COL 85 WIDGET-ID 60
     T-O AT ROW 3.25 COL 91 WIDGET-ID 64
     tt-prop-map.node-type AT ROW 3.67 COL 9 COLON-ALIGNED WIDGET-ID 18
          LABEL "Тип узла" FORMAT "9"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Item 1",1
          DROP-DOWN-LIST
          SIZE 24.5 BY 1
     tt-prop-map.node-value-type AT ROW 3.67 COL 46 COLON-ALIGNED WIDGET-ID 20
          LABEL "Тип данных" FORMAT "X(20)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 23 BY 1
     tt-prop-map.is-collection AT ROW 5 COL 11 WIDGET-ID 54
          LABEL "Коллекция"
          VIEW-AS TOGGLE-BOX
          SIZE 24 BY 1
     cb-object-type AT ROW 5 COL 46 COLON-ALIGNED WIDGET-ID 42
     tt-prop-map.is-term AT ROW 5 COL 74.5 WIDGET-ID 62
          LABEL "Терминальный"
          VIEW-AS TOGGLE-BOX
          SIZE 16.5 BY 1.07
     tt-prop-map.node-name AT ROW 6.33 COL 15 COLON-ALIGNED WIDGET-ID 16
          LABEL "Имя свойства"
          VIEW-AS FILL-IN
          SIZE 76.5 BY 1
     tt-prop-map.node-label AT ROW 7.67 COL 15 COLON-ALIGNED WIDGET-ID 22
          LABEL "Лейбл" FORMAT "x(255)"
          VIEW-AS FILL-IN
          SIZE 76.5 BY 1
     tt-prop-map.init-value-character AT ROW 9 COL 15 COLON-ALIGNED WIDGET-ID 24
          LABEL "Нач.знач." FORMAT "X(255)"
          VIEW-AS FILL-IN
          SIZE 76.5 BY 1
     tt-prop-map.init-value-date AT ROW 10.33 COL 15 COLON-ALIGNED WIDGET-ID 26
          LABEL "Нач.знач."
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-prop-map.node-format AT ROW 10.57 COL 62.5 COLON-ALIGNED WIDGET-ID 52
          LABEL "Формат" FORMAT "X(22)"
          VIEW-AS FILL-IN
          SIZE 29 BY 1
     tt-prop-map.init-value-decimal AT ROW 11.67 COL 15 COLON-ALIGNED WIDGET-ID 28
          LABEL "Нач.знач." FORMAT "->,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 28.5 BY 1
     tt-prop-map.init-value-integer AT ROW 13 COL 15 COLON-ALIGNED WIDGET-ID 30
          LABEL "Нач.знач."
          VIEW-AS FILL-IN
          SIZE 28.5 BY 1
     tt-prop-map.init-value-logical AT ROW 14.33 COL 17 WIDGET-ID 34
          LABEL "Нач.знач."
          VIEW-AS TOGGLE-BOX
          SIZE 23.5 BY .8
     tt-prop-map.node-description AT ROW 16.2 COL 1 NO-LABEL WIDGET-ID 12
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 6.57
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
DEFINE FRAME Dialog-Frame
     "Описание" VIEW-AS TEXT
          SIZE 14.5 BY .77 AT ROW 15.13 COL 1.5 WIDGET-ID 14
     SPACE(83.50) SKIP(7.34)
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
ON CHOOSE OF b-upper-code IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-map FOR ub.prop-map.
    run rul/prop-map-s.w (
                           input parparentproc
                          ,INPUT 'b-sel':U
                          ,INPUT "dtm-code"
                          ,INPUT tt-prop-map.dtm-code
                          ,INPUT-OUTPUT v-rid-list) NO-ERROR.
IF ERROR-STATUS:ERROR
OR v-rid-list = '':U THEN RETURN NO-APPLY.
FIND FIRST buf_prop-map NO-LOCK WHERE
          recid(buf_prop-map) = INTEGER(v-rid-list).
ASSIGN
tt-prop-map.upper-node-code = buf_prop-map.node-code
tt-prop-map.upper-node-name = buf_prop-map.node-name
.
DISPLAY
tt-prop-map.upper-node-code
tt-prop-map.upper-node-name
WITH FRAME Dialog-Frame.
END.
ON LEAVE OF tt-prop-map.dtm-code IN FRAME Dialog-Frame
DO:
  ASSIGN
  tt-prop-map.dtm-code.
END.
ON VALUE-CHANGED OF tt-prop-map.node-value-type IN FRAME Dialog-Frame
DO:
  ASSIGN
  tt-prop-map.node-value-type.
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
  IF p-dtm-code = 0 THEN DO:
    MESSAGE "Не задан ID термина в словаре"
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
  IF p-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
    FIND FIRST locked_prop-head EXCLUSIVE-LOCK WHERE
            LOCKED_prop-head.dtm-code = p-dtm-code .
    CREATE tt-prop-map.
    FIND LAST LAST_prop-map NO-LOCK WHERE
            last_prop-map.dtm-code = p-dtm-code  NO-ERROR.
    ASSIGN
    tt-prop-map.node-code = (IF AVAILABLE LAST_prop-map
                                  THEN LAST_prop-map.node-code + 1
                                  ELSE 1)
    tt-prop-map.dtm-code = (if p-dtm-code > 0 then p-dtm-code else 0)
    .
  END.
  else do:
    IF p-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
        FIND FIRST locked_prop-head EXCLUSIVE-LOCK WHERE
                LOCKED_prop-head.dtm-code = p-dtm-code .
        FIND FIRST locked_prop-map EXCLUSIVE-LOCK WHERE
                LOCKED_prop-map.dtm-code = p-dtm-code
            AND LOCKED_prop-map.node-code = p-node-code.
    END.
    IF p-mode = 'ПРОСМОТР':U THEN DO:
        FIND FIRST locked_prop-head no-lock WHERE
                LOCKED_prop-head.dtm-code = p-dtm-code
            .
        FIND FIRST locked_prop-map no-LOCK WHERE
                LOCKED_prop-map.dtm-code = p-dtm-code
            AND LOCKED_prop-map.node-code = p-node-code.
    END.
    create tt-prop-map.
    buffer-copy locked_prop-map to tt-prop-map.
  end.
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-prop-map SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY T-R T-W T-C T-O cb-object-type
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-prop-map THEN
    DISPLAY tt-prop-map.dtm-code tt-prop-map.node-code tt-prop-map.upper-node-code
          tt-prop-map.upper-node-name tt-prop-map.node-type
          tt-prop-map.node-value-type tt-prop-map.is-collection
          tt-prop-map.is-term tt-prop-map.node-name tt-prop-map.node-label
          tt-prop-map.init-value-character tt-prop-map.init-value-date
          tt-prop-map.node-format tt-prop-map.init-value-decimal
          tt-prop-map.init-value-integer tt-prop-map.init-value-logical
          tt-prop-map.node-description
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit tt-prop-map.dtm-code tt-prop-map.node-code B-Help
         tt-prop-map.upper-node-code b-upper-code T-R T-W T-C T-O
         tt-prop-map.node-type tt-prop-map.node-value-type
         tt-prop-map.is-collection cb-object-type tt-prop-map.is-term
         tt-prop-map.node-name tt-prop-map.node-label
         tt-prop-map.init-value-character tt-prop-map.init-value-date
         tt-prop-map.node-format tt-prop-map.init-value-decimal
         tt-prop-map.init-value-integer tt-prop-map.init-value-logical
         tt-prop-map.node-description
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-item-pairs AS CHARACTER NO-UNDO.
DO v-ii = 1 TO NUM-ENTRIES('1,3,2,4,5,6,7,8,9':U):
  ASSIGN
  v-item-pairs = v-item-pairs + chr(44) +
                 ENTRY(v-ii,'Элемент,Текст,ТипДокумента,ЧастьДокумента,Ссылка,Атрибут,CDATA,Комментарий,Инструкция':U) + chr(44) + ENTRY(v-ii,'1,3,2,4,5,6,7,8,9':U).
END.
v-item-pairs = TRIM(v-item-pairs, chr(44)).
ASSIGN
tt-prop-map.node-value-type:LIST-ITEMS IN FRAME Dialog-Frame = 'character,date,decimal,integer,logical':U
tt-prop-map.node-type:LIST-ITEM-PAIRS IN FRAME Dialog-Frame = v-item-pairs
cb-object-type:LIST-ITEMS IN FRAME Dialog-Frame = ",r-b,dis-card"
.
assign
cb-object-type = (if num-entries(tt-prop-map.node-value-type) > 1
                  then entry(2, tt-prop-map.node-value-type)
                  else '':U)
tt-prop-map.node-value-type = entry(1, tt-prop-map.node-value-type)
t-r = (index(tt-prop-map.rw-option, "R") > 0)
t-W = (index(tt-prop-map.rw-option, "W") > 0)
t-C = (index(tt-prop-map.rw-option, "C") > 0)
t-O = (index(tt-prop-map.rw-option, "O") > 0)
.
IF AVAILABLE tt-prop-map THEN
DISPLAY
t-r
t-w
t-c
t-o
tt-prop-map.dtm-code
tt-prop-map.node-code
tt-prop-map.upper-node-code
tt-prop-map.upper-node-name
tt-prop-map.node-type
tt-prop-map.node-value-type
tt-prop-map.node-name
tt-prop-map.node-format
tt-prop-map.is-collection
tt-prop-map.node-label
tt-prop-map.is-term
tt-prop-map.init-value-character WHEN tt-prop-map.node-value-type = 'character':U
tt-prop-map.init-value-date WHEN tt-prop-map.node-value-type = 'date':U
tt-prop-map.init-value-decimal WHEN tt-prop-map.node-value-type = 'decimal':U
tt-prop-map.init-value-integer WHEN tt-prop-map.node-value-type = 'integer':U
tt-prop-map.init-value-logical WHEN tt-prop-map.node-value-type = 'logical':U
tt-prop-map.node-description
WITH FRAME Dialog-Frame .
ENABLE
B-exit  when p-mode <> 'ПРОСМОТР':U
b-quit
B-Help
tt-prop-map.dtm-code when (p-mode = 'ДОБАВЛЕНИЕ':U and p-dtm-code = 0)
tt-prop-map.node-type when p-mode <> 'ПРОСМОТР':U
tt-prop-map.node-value-type when p-mode <> 'ПРОСМОТР':U
tt-prop-map.node-name       when p-mode <> 'ПРОСМОТР':U
tt-prop-map.node-label when p-mode <> 'ПРОСМОТР':U
tt-prop-map.node-format when p-mode <> 'ПРОСМОТР':U
tt-prop-map.node-description when p-mode <> 'ПРОСМОТР':U
tt-prop-map.is-term when p-mode <> 'ПРОСМОТР':U
b-upper-code WHEN p-mode <> 'ПРОСМОТР':U
t-r WHEN p-mode <> 'ПРОСМОТР':U
t-w WHEN p-mode <> 'ПРОСМОТР':U
t-c WHEN p-mode <> 'ПРОСМОТР':U
t-o WHEN p-mode <> 'ПРОСМОТР':U
WITH FRAME Dialog-Frame .
if p-mode = 'ПРОСМОТР':U then do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1.
  hide b-exit in frame Dialog-Frame .
end.
VIEW FRAME Dialog-Frame .
RUN switch-data-type IN THIS-PROCEDURE .
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS recID  NO-UNDO.
IF p-mode = 'ПРОСМОТР':U THEN DO:
    RETURN.
END.
IF p-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
  v-rec = p-rec .
END.
ASSIGN
FRAME Dialog-Frame
t-r
t-w
t-c
t-o
tt-prop-map.dtm-code
tt-prop-map.node-code
tt-prop-map.upper-node-code
tt-prop-map.upper-node-name
tt-prop-map.rw-option = (IF t-r THEN "R" ELSE "":U) +
                        (IF t-W THEN "W" ELSE "":U) +
                        (IF t-c THEN "C" ELSE "":U) +
                        (IF t-o THEN "O" ELSE "":U)
tt-prop-map.node-type
tt-prop-map.node-name
tt-prop-map.node-label
tt-prop-map.is-term
cb-object-type
tt-prop-map.node-value-type
tt-prop-map.node-value-type = tt-prop-map.node-value-type + chr(44) + cb-object-type
tt-prop-map.node-description
tt-prop-map.is-collection
tt-prop-map.node-format
tt-prop-map.init-value-character WHEN tt-prop-map.node-value-type = 'character':U
tt-prop-map.init-value-date WHEN tt-prop-map.node-value-type = 'date':U
tt-prop-map.init-value-decimal WHEN tt-prop-map.node-value-type = 'decimal':U
tt-prop-map.init-value-integer WHEN tt-prop-map.node-value-type = 'integer':U
tt-prop-map.init-value-logical WHEN tt-prop-map.node-value-type = 'logical':U
.
run rul/prop-map1.p ( INPUT p-mode
                ,INPUT NO
                ,INPUT-OUTPUT v-rec
                ,INPUT tt-prop-map.dtm-code
                ,INPUT tt-prop-map.node-code
                ,INPUT tt-prop-map.upper-node-code
                ,INPUT tt-prop-map.upper-node-name
                ,INPUT tt-prop-map.node-type
                ,INPUT tt-prop-map.is-collection
                ,INPUT tt-prop-map.rw-option
                ,INPUT tt-prop-map.node-name
                ,INPUT tt-prop-map.node-label
                ,INPUT tt-prop-map.node-value-type
                ,INPUT tt-prop-map.node-format
                ,INPUT tt-prop-map.node-description
                ,INPUT tt-prop-map.is-term
                ,INPUT tt-prop-map.init-value-character
                ,INPUT tt-prop-map.init-value-date
                ,INPUT tt-prop-map.init-value-decimal
                ,INPUT tt-prop-map.init-value-integer
                ,INPUT tt-prop-map.init-value-logical
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
PROCEDURE switch-data-type :
HIDE
tt-prop-map.init-value-character  IN FRAME Dialog-Frame
tt-prop-map.init-value-date
tt-prop-map.init-value-decimal
tt-prop-map.init-value-integer
tt-prop-map.init-value-logical
.
DISABLE
tt-prop-map.init-value-character
tt-prop-map.init-value-date
tt-prop-map.init-value-decimal
tt-prop-map.init-value-integer
tt-prop-map.init-value-logical
with FRAME Dialog-Frame.
CASE tt-prop-map.node-value-type:
  WHEN 'character':U THEN DO:
     DISPLAY
     tt-prop-map.init-value-character
     WITH FRAME Dialog-Frame.
     ENABLE
     tt-prop-map.init-value-character WHEN p-mode <> 'ПРОСМОТР':U
     WITH FRAME Dialog-Frame.
  END.
  WHEN 'date':U THEN DO:
     DISPLAY
     tt-prop-map.init-value-date
     WITH FRAME Dialog-Frame.
     ENABLE
     tt-prop-map.init-value-date WHEN p-mode <> 'ПРОСМОТР':U
     WITH FRAME Dialog-Frame.
  END.
  WHEN 'decimal':U THEN DO:
     DISPLAY
     tt-prop-map.init-value-decimal
     WITH FRAME Dialog-Frame.
     ENABLE
     tt-prop-map.init-value-decimal WHEN p-mode <> 'ПРОСМОТР':U
     WITH FRAME Dialog-Frame.
  END.
  WHEN 'integer':U THEN DO:
     DISPLAY
     tt-prop-map.init-value-integer
     WITH FRAME Dialog-Frame.
     ENABLE
     tt-prop-map.init-value-integer WHEN p-mode <> 'ПРОСМОТР':U
     WITH FRAME Dialog-Frame.
  END.
  WHEN 'logical':U THEN DO:
     DISPLAY
     tt-prop-map.init-value-logical
     WITH FRAME Dialog-Frame.
     ENABLE
     tt-prop-map.init-value-logical WHEN p-mode <> 'ПРОСМОТР':U
     WITH FRAME Dialog-Frame.
  END.
END CASE.
END PROCEDURE.
PROCEDURE switch-main-widgets :
DEFINE INPUT parameter p-mode AS CHARACTER NO-UNDO.
define buffer buf_prop-script for ub.prop-script.
find first buf_prop-script NO-LOCK WHERE
            buf_prop-script.dtm-code = tt-prop-map.dtm-code  no-error.
IF AVAILABLE buf_prop-script THEN DO:
END.
IF (LOCKED_prop-head.storage-place = '':U
   OR LOCKED_prop-head.storage-place = chr(63)
    )
    AND
    (LOCKED_prop-head.storage-place-host = '':U
     OR
     LOCKED_prop-head.storage-place-host = chr(63))
AND
    (LOCKED_prop-head.storage-place-obj = '':U
     OR
     LOCKED_prop-head.storage-place-obj = chr(63))
    THEN DO:
END.
END PROCEDURE.
