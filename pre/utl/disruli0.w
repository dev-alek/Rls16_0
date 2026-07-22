DEFINE BUFFER locked_dis-rule FOR ub.dis-rule.
DEFINE TEMP-TABLE temp-drt-prop NO-UNDO LIKE ub.drt-prop
       field upper-prop-label as character
       field prop-label as character
       .
DEFINE TEMP-TABLE tt-dis-rule NO-UNDO LIKE ub.dis-rule.
DEFINE TEMP-TABLE tt-drt-prop NO-UNDO LIKE ub.drt-prop
       field full-prop-name as character.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-templ-rl-root AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-rec AS RECID NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка нового шаблона скидки".
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
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
DEFINE STREAM instream.
DEFINE VARIABLE add-option AS CHARACTER NO-UNDO.
define buffer locked_dis-cfg-rule for ub.dis-cfg-rule.
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON b-del
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
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE F-level-1 AS CHARACTER FORMAT "X(256)":U
     LABEL "Уровень1"
     VIEW-AS FILL-IN
     SIZE 75 BY 1 NO-UNDO.
DEFINE VARIABLE F-level-2 AS CHARACTER FORMAT "X(256)":U
     LABEL "Уровень2"
     VIEW-AS FILL-IN
     SIZE 75 BY 1 NO-UNDO.
DEFINE VARIABLE tg-has-global AS LOGICAL INITIAL no
     LABEL "Бывает глобальной"
     VIEW-AS TOGGLE-BOX
     SIZE 22.5 BY .83 NO-UNDO.
DEFINE VARIABLE tg-has-host AS LOGICAL INITIAL no
     LABEL "Бывает фирма"
     VIEW-AS TOGGLE-BOX
     SIZE 21.5 BY .83 NO-UNDO.
DEFINE VARIABLE tg-has-object AS LOGICAL INITIAL no
     LABEL "Бывает по объекту"
     VIEW-AS TOGGLE-BOX
     SIZE 22 BY .83 NO-UNDO.
DEFINE QUERY br-drt-prop FOR
      tt-drt-prop SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      tt-dis-rule SCROLLING.
DEFINE BROWSE br-drt-prop
  QUERY br-drt-prop NO-LOCK DISPLAY
      tt-drt-prop.node-code COLUMN-LABEL "код" FORMAT ">>9"
tt-drt-prop.upper-node-code COLUMN-LABEL "выш.!код" FORMAT ">>9"
tt-drt-prop.full-prop-name COLUMN-LABEL "Свойство" FORMAT "X(255)" WIDTH 40
tt-drt-prop.property-value COLUMN-LABEL "Значение" FORMAT "X(255)" WIDTH 58
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.87 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     tt-dis-rule.templ-rl-root AT ROW 1 COL 43 COLON-ALIGNED WIDGET-ID 4
          LABEL "Код шаблона"
          VIEW-AS FILL-IN
          SIZE 5 BY 1
     B-Help AT ROW 1 COL 95
     tt-dis-rule.des AT ROW 2 COL 4 WIDGET-ID 6
          LABEL "Описание"
          VIEW-AS FILL-IN
          SIZE 84.5 BY 1
     tt-dis-rule.discnt-type AT ROW 3 COL 25 COLON-ALIGNED WIDGET-ID 8
          LABEL "Описательный тип скидки" FORMAT ">>>9"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "0",1
          DROP-DOWN-LIST
          SIZE 25.5 BY 1
     tt-dis-rule.other-inf AT ROW 4 COL 2.6 WIDGET-ID 10
          LABEL "Другая инф" FORMAT "X(90)"
          VIEW-AS FILL-IN
          SIZE 84.5 BY 1
     tt-dis-rule.subject-type AT ROW 5 COL 19 COLON-ALIGNED WIDGET-ID 12
          LABEL "Объект воздейств"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Item 1",0
          DROP-DOWN-LIST
          SIZE 22 BY 1
     tt-dis-rule.uniq-field AT ROW 5 COL 51 COLON-ALIGNED WIDGET-ID 14
          LABEL "Дерево" FORMAT "X(65)"
          VIEW-AS FILL-IN
          SIZE 46 BY 1
     F-level-1 AT ROW 6.27 COL 14.5 COLON-ALIGNED WIDGET-ID 72
     F-level-2 AT ROW 7.5 COL 14.5 COLON-ALIGNED WIDGET-ID 74
     tt-dis-rule.sts AT ROW 10 COL 1 NO-LABEL WIDGET-ID 42
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS
                    "Item 1", 0,
"Item 2", 1
          SIZE 15.5 BY 1.87
     tg-has-global AT ROW 10.27 COL 74.5 WIDGET-ID 62
     tg-has-host AT ROW 11.27 COL 74.5 WIDGET-ID 64
     b-add AT ROW 12.27 COL 1 WIDGET-ID 36
     b-del AT ROW 12.27 COL 11 WIDGET-ID 38
     b-chg AT ROW 12.27 COL 21 WIDGET-ID 40
     tt-dis-rule.value-type AT ROW 12.27 COL 45 COLON-ALIGNED WIDGET-ID 16
          LABEL "Тип значения"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Item 1",0
          DROP-DOWN-LIST
          SIZE 26 BY 1
     tg-has-object AT ROW 12.27 COL 74.5 WIDGET-ID 66
     br-drt-prop AT ROW 13.27 COL 1 WIDGET-ID 100
     "Статус" VIEW-AS TEXT
          SIZE 9 BY .8 AT ROW 9 COL 1 WIDGET-ID 46
     SPACE(89.13) SKIP(13.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Название  секции"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
  define variable v-node-code as integer   no-undo .
  RUN proc-b-add IN THIS-PROCEDURE ( output v-node-code) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  if not available tt-drt-prop or v-node-code = ? then return no-apply.
  run proc-b-chg in this-procedure no-error .
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE tt-drt-prop THEN RETURN NO-APPLY.
  RUN proc-b-chg IN THIS-PROCEDURE NO-ERROR.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE tt-drt-prop THEN RETURN NO-APPLY.
  RUN proc-b-del IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
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
        v-diasize-browse-handle     = browse br-drt-prop :handle
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
      CREATE tt-dis-rule.
    END.
    WHEN 'ИЗМЕНЕНИЕ':U THEN DO:
       FIND FIRST LOCKED_dis-rule EXCLUSIVE-LOCK where
               LOCKED_dis-rule.rule-num = p-templ-rl-root .
      CREATE tt-dis-rule.
      BUFFER-COPY LOCKED_dis-rule TO tt-dis-rule.
      find first locked_dis-cfg-rule exclusive-lock where
                locked_dis-cfg-rule.templ-rl-root = p-templ-rl-root
            and locked_dis-cfg-rule.table-name = '':U
            and locked_dis-cfg-rule.pos-type = '':U
            and locked_dis-cfg-rule.self-nonunique = '':U.
    END.
    WHEN 'ПРОСМОТР':U
    or when 'КОПИРОВАНИЕ':U
    THEN DO:
        FIND FIRST LOCKED_dis-rule no-lock where
              LOCKED_dis-rule.rule-num = p-templ-rl-root.
      CREATE tt-dis-rule.
      BUFFER-COPY LOCKED_dis-rule
      except templ-rl-root
             rule-num
             rl-root
      TO tt-dis-rule
      assign
      tt-dis-rule.templ-rl-root = (if p-mode = 'КОПИРОВАНИЕ':U
                                   then 0
                                   else locked_dis-rule.templ-rl-root )
      tt-dis-rule.rl-root = (if p-mode = 'КОПИРОВАНИЕ':U
                             then 0
                             else locked_dis-rule.rl-root)
      tt-dis-rule.rule-num = (if p-mode = 'КОПИРОВАНИЕ':U
                              then 0
                              else locked_dis-rule.rule-num)
      .
      find first locked_dis-cfg-rule no-lock where
                locked_dis-cfg-rule.templ-rl-root = p-templ-rl-root
            and locked_dis-cfg-rule.table-name = '':U
            and locked_dis-cfg-rule.pos-type = '':U
            and locked_dis-cfg-rule.self-nonunique = '':U.
    END.
  END CASE.
  if p-mode = 'КОПИРОВАНИЕ':U then do:
    assign
    v-is-copy = yes
    p-mode = 'ДОБАВЛЕНИЕ':U
    .
  end.
  RUN fill-temp-drt-prop IN THIS-PROCEDURE.
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY F-level-1 F-level-2 tg-has-global tg-has-host tg-has-object
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-dis-rule THEN
    DISPLAY tt-dis-rule.templ-rl-root tt-dis-rule.des tt-dis-rule.discnt-type
          tt-dis-rule.other-inf tt-dis-rule.subject-type tt-dis-rule.uniq-field
          tt-dis-rule.sts tt-dis-rule.value-type
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit tt-dis-rule.templ-rl-root B-Help tt-dis-rule.des
         tt-dis-rule.discnt-type tt-dis-rule.other-inf tt-dis-rule.subject-type
         tt-dis-rule.uniq-field F-level-1 F-level-2 tt-dis-rule.sts
         tg-has-global tg-has-host b-add b-del b-chg tt-dis-rule.value-type
         tg-has-object br-drt-prop
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-temp-drt-prop :
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
DEFINE VARIABLE v-start AS LOGICAL NO-UNDO INIT YES.
DEFINE VARIABLE v-node-code AS integer NO-UNDO.
DEFINE BUFFER buf_drt-prop FOR  ub.drt-prop.
DEFINE BUFFER upper_drt-prop FOR ub.drt-prop.
DEFINE BUFFER buf_tt-drt-prop FOR tt-drt-prop.
_buf_drt-prop:
FOR EACH buf_drt-prop NO-LOCK WHERE
        buf_drt-prop.templ-rl-root = p-templ-rl-root:
  CREATE buf_tt-drt-prop.
  BUFFER-COPY buf_drt-prop TO buf_tt-drt-prop
  .
  if v-is-copy = yes then do:
    assign
    buf_tt-drt-prop.templ-rl-root = -1.
  end.
  v-start = YES.
  FIND FIRST UPPER_drt-prop NO-LOCK WHERE
            UPPER_drt-prop.upper-node-code = buf_drt-prop.upper-node-code
        AND UPPER_drt-prop.node-code = buf_drt-prop.node-code
        AND UPPER_drt-prop.templ-rl-root = buf_drt-prop.templ-rl-root.
  DO WHILE v-start OR buf_drt-prop.upper-node-code <> 0:
    v-start = NO.
    IF AVAILABLE UPPER_drt-prop THEN DO:
      ASSIGN
      buf_tt-drt-prop.full-prop-name = UPPER_drt-prop.prop-code +
                                          chr(47) +
                                      buf_tt-drt-prop.full-prop-name.
    END.
    v-node-code = upper_drt-prop.upper-node-code.
    FIND FIRST UPPER_drt-prop NO-LOCK WHERE
               UPPER_drt-prop.node-code = v-node-code
            AND UPPER_drt-prop.templ-rl-root = buf_drt-prop.templ-rl-root NO-ERROR.
    IF NOT AVAILABLE UPPER_drt-prop THEN next _buf_drt-prop.
  END.
END.
CREATE tt-drt-prop.
ASSIGN
tt-drt-prop.prop-code = '':U
tt-drt-prop.node-code = 0
tt-drt-prop.upper-prop-code = '':U
tt-drt-prop.upper-node-code = 0
tt-drt-prop.templ-rl-root = (if v-is-copy then - 1 else p-templ-rl-root)
.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-list-items AS CHARACTER  NO-UNDO.
DEFINE VARIABLE v-ii AS integer  NO-UNDO.
assign
tt-drt-prop.full-prop-name:resizable in browse br-drt-prop = yes
tt-drt-prop.property-value:resizable in browse br-drt-prop = yes
.
DO v-ii = 1 TO NUM-ENTRIES('0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,23,17,18,19,20,21,22,998,999,1001':U):
    ASSIGN
    v-list-items = v-list-items +  (IF v-ii > 1 then chr(44) ELSE '':U) +
                   ENTRY(v-ii, '?,Клиент,Стандарт,Временная,Количество,Сумма,Персонал,Промо,Уценка,Счастл.час,Комплект,Сезонная,Катег,Ручная,Карта-маска,Округл. в пользу.клиента,Катег с исп шаблона,Оплата топливным купоном (Ашан),Абсолютная,Группа,Платеж,ЛНР,Округление,Оплата,Доп.условие,Другое,Погрешность':U) + chr(44) +
                   ENTRY(v-ii, '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,23,17,18,19,20,21,22,998,999,1001':U).
END.
ASSIGN
tt-dis-rule.discnt-type:LIST-ITEM-PAIRS IN FRAME Dialog-Frame = v-list-items.
v-list-items = '':U.
DO v-ii = 1 TO NUM-ENTRIES('0,1,2,3,4,5,6,7,8,9,10,11,12,13,14':U):
    ASSIGN
    v-list-items = v-list-items +  (IF v-ii > 1 then chr(44) ELSE '':U) +
                   ENTRY(v-ii, '?,%,Абс,ФЦ,опция,Бонус,Категория,Флаг,Правило,%-Абс-ФЦ,Сумма,ТПЛ-%,ТПЛ-ФЦ,ТПЛ-абс,Подарок':U) + chr(44) +
                   ENTRY(v-ii, '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14':U).
END.
ASSIGN
tt-dis-rule.value-type:LIST-ITEM-PAIRS = v-list-items.
v-list-items = '':U.
DO v-ii = 1 TO NUM-ENTRIES('0,1,2,3,4,5,7,8':U):
    ASSIGN
    v-list-items = v-list-items +  (IF v-ii > 1 then chr(44) ELSE '':U) +
                   ENTRY(v-ii, 'Неизв,Товар,Подитог,Итог,Чек,Оплата,Товар_б/итог.скидки,Группа':U) + chr(44) +
                   ENTRY(v-ii, '0,1,2,3,4,5,7,8':U).
END.
ASSIGN
tt-dis-rule.subject:LIST-ITEM-PAIRS = v-list-items.
assign
tt-dis-rule.sts:radio-buttons in frame Dialog-Frame = "Текущий"   + chr(44) + '0':U +  chr(44) +
                                                   "Нетекущий" + chr(44) + '1':U
.
if available locked_dis-cfg-rule then do:
  ASSIGN
  f-level-1 = entry(1, locked_dis-cfg-rule.other-inf, ";":U)
  f-level-2 = (if num-entries(locked_dis-cfg-rule.other-inf, ";":U) > 1
              then entry(2, locked_dis-cfg-rule.other-inf, ";":U)
              else '')
  tg-has-global = locked_dis-cfg-rule.has-global <> 0
  tg-has-host = locked_dis-cfg-rule.has-host <> 0
  tg-has-object = locked_dis-cfg-rule.has-obj <> 0
  .
end.
DISPLAY
f-level-1
f-level-2
WITH FRAME Dialog-Frame.
IF AVAILABLE tt-dis-rule THEN
DISPLAY
tt-dis-rule.templ-rl-root
tt-dis-rule.des
tt-dis-rule.discnt-type
tt-dis-rule.other-inf
tt-dis-rule.subject-type
tt-dis-rule.uniq-field
tt-dis-rule.value-type
tt-dis-rule.sts
tg-has-global
tg-has-host
tg-has-object
WITH FRAME Dialog-Frame.
ENABLE
B-exit WHEN p-mode <> 'ПРОСМОТР':U
b-quit
B-Help
tt-dis-rule.templ-rl-root WHEN p-mode = 'ДОБАВЛЕНИЕ':U
tt-dis-rule.des WHEN p-mode <> 'ПРОСМОТР':U
tt-dis-rule.discnt-type WHEN p-mode <> 'ПРОСМОТР':U
tt-dis-rule.other-inf WHEN p-mode <> 'ПРОСМОТР':U
tt-dis-rule.subject-type WHEN p-mode <> 'ПРОСМОТР':U
tt-dis-rule.uniq-field WHEN p-mode <> 'ПРОСМОТР':U
tt-dis-rule.value-type WHEN p-mode <> 'ПРОСМОТР':U
tt-dis-rule.sts when p-mode <> 'ПРОСМОТР':U
f-level-1 when p-mode <> 'ПРОСМОТР':U
f-level-2 when p-mode <> 'ПРОСМОТР':U
b-add WHEn p-mode <> 'ПРОСМОТР':U
b-del WHEn p-mode <> 'ПРОСМОТР':U
b-chg WHEn p-mode <> 'ПРОСМОТР':U
tg-has-global when p-mode <> 'ПРОСМОТР':U
tg-has-host when p-mode <> 'ПРОСМОТР':U
tg-has-object when p-mode <> 'ПРОСМОТР':U
br-drt-prop
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
if p-mode = 'ПРОСМОТР':U then do:
  hide
  b-exit
  in frame Dialog-Frame .
  assign
  b-quit:column = 1
  b-quit:label = "&Выход"
  .
end.
RUN OPENbr IN THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE Openbr :
OPEN QUERY br-drt-prop FOR EACH tt-drt-prop by tt-drt-prop.full-prop-name.
END PROCEDURE.
PROCEDURE proc-b-add :
define output parameter p-node-code     as integer initial ?  no-undo .
DEFINE VARIABLE v-upper-prop-code       AS CHARACTER NO-UNDO .
define variable v-upper-node-code       as integer   no-undo .
DEFINE VARIABLE v-upper-prop-label      AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-full-prop-name        AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-upper-full-prop-name  AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-prop-code             AS CHARACTER NO-UNDO .
define variable v-node-code             as integer   no-undo .
DEFINE VARIABLE v-prop-label            AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-property-value        AS CHARACTER NO-UNDO .
DEFINE BUFFER buf_tt-drt-prop FOR tt-drt-prop.
run utl/drtpropi.w (  INPUT parparentproc
                     ,output v-upper-prop-code
                     ,output v-upper-node-code
                     ,OUTPUT v-upper-prop-label
                     ,OUTPUT v-full-prop-name
                     ,OUTPUT v-prop-code
                     ,output v-node-code
                     ,OUTPUT v-prop-label
                     ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN undo, RETURN ERROR.
if v-prop-code = '':u then return.
FIND FIRST buf_tt-drt-prop WHERE
          buf_tt-drt-prop.full-prop-name = v-full-prop-name NO-ERROR.
IF AVAILABLE buf_tt-drt-prop THEN DO:
   MESSAGE
  "Уже есть такой параметр в такой секции" SKIP
   v-full-prop-name
   VIEW-AS ALERT-BOX ERROR.
   UNDO, RETURN ERROR.
END.
ASSIGN
v-UPPER-full-prop-name = v-full-prop-name
.
ASSIGN
v-upper-full-prop-name = RIGHT-TRIM(v-upper-full-prop-name, chr(47))
.
ENTRY(NUM-ENTRIES(v-upper-full-prop-name, chr(47)), v-upper-full-prop-name, chr(47)) = '':U.
FIND FIRST buf_tt-drt-prop WHERE
          buf_tt-drt-prop.full-prop-name = v-upper-full-prop-name NO-ERROR.
IF NOT AVAILABLE buf_tt-drt-prop THEN DO:
   MESSAGE
  "Нет секции с полным именем ="
   v-upper-full-prop-name
   VIEW-AS ALERT-BOX ERROR.
   UNDO, RETURN ERROR.
END.
CREATE buf_tt-drt-prop.
ASSIGN
buf_tt-drt-prop.prop-code       = v-prop-code
buf_tt-drt-prop.node-code       = v-node-code
buf_tt-drt-prop.upper-prop-code = v-upper-prop-code
buf_tt-drt-prop.upper-node-code = v-upper-node-code
buf_tt-drt-prop.property-value  = v-property-value
buf_tt-drt-prop.full-prop-name  = v-full-prop-name
buf_tt-drt-prop.templ-rl-root   = p-templ-rl-root
p-node-code                     = v-node-code
.
release buf_tt-drt-prop.
RUN openbr IN THIS-PROCEDURE .
find first buf_tt-drt-prop no-lock
  where buf_tt-drt-prop.templ-rl-root = p-templ-rl-root
    and buf_tt-drt-prop.node-code     = v-node-code
no-error .
if available buf_tt-drt-prop  then do:
  REPOSITION  br-drt-prop TO RECID RECID(buf_tt-drt-prop) NO-ERROR.
end.
APPLY "ENTRY" TO BROWSE br-drt-prop.
END PROCEDURE.
PROCEDURE proc-b-chg :
DEFINE VARIABLE v-value AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
v-value = tt-drt-prop.property-value.
if tt-drt-prop.upper-prop-code = "Run-params" then do:
  run utl/drt-cp.w (
                     INPUT 'ИЗМЕНЕНИЕ':U
                   ,input tt-drt-prop.prop-code
                   ,input-output v-value
                   ) no-error.
end.
else do:
  run gbl/d-character.w (
        input ?
      ,input (
      'title=':u + substitute("Изменение свойства &1", tt-drt-prop.prop-code) + '\':u
    + 'text1=':u + tt-drt-prop.prop-code + '\':u
    + 'format=' + "X(90)" + '\':u
    + 'fillin_row=3\':u
    + 'fillin_col=4\':u
    + 'fillin_width=90\':u
    + 'fillin_height=1\':u
    + 'max-chars=90\':u
    + 'readonly=no' + '\':u)
    , input-output v-value
    , output v-ok
        ).
    if not v-ok then return error.
end.
assign
tt-drt-prop.property-value = v-value.
br-drt-prop:REFRESH() IN FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-del :
DEFINE VARIABLE glog AS LOGICAL no-undo.
DEFINE BUFFER buf_tt-drt-prop FOR tt-drt-prop.
MESSAGE
SUBSTITUTE("Вы уверены, что хотите удалить свойство?")
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
IF NOT glog  THEN RETURN ERROR.
FIND FIRST buf_tt-drt-prop WHERE
          buf_tt-drt-prop.upper-node-code = tt-drt-prop.node-code  NO-ERROR.
IF AVAILABLE buf_tt-drt-prop THEN DO:
  MESSAGE
  "Нельзя удалить свойство, к нему есть привязки"
   VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
END.
FIND FIRST buf_tt-drt-prop WHERE
         RECID(buf_tt-drt-prop) = RECID(tt-drt-prop).
DELETE buf_tt-drt-prop.
RUN Openbr IN THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE proc-save :
define buffer buf_tt-drt-prop for tt-drt-prop.
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
IF p-mode = 'ПРОСМОТР':U THEN RETURN .
IF p-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
  v-rec = p-rec.
END.
ASSIGN
FRAME Dialog-Frame
tt-dis-rule.templ-rl-root
tt-dis-rule.des
tt-dis-rule.discnt-type
tt-dis-rule.other-inf
tt-dis-rule.subject-type
tt-dis-rule.uniq-field
tt-dis-rule.value-type
tt-dis-rule.sts
f-level-1
f-level-2
tg-has-global
tg-has-host
tg-has-object
.
for each buf_tt-drt-prop:
  assign
  buf_tt-drt-prop.templ-rl-root = tt-dis-rule.templ-rl-root
  .
end.
run utl/disrul0.p ( INPUT p-mode
                    ,INPUT NO
                    ,INPUT-output v-rec
                    ,INPUT tt-dis-rule.templ-rl-root
                    ,INPUT tt-dis-rule.des
                    ,INPUT tt-dis-rule.discnt-type
                    ,INPUT tt-dis-rule.other-inf
                    ,INPUT tt-dis-rule.subject-type
                    ,INPUT tt-dis-rule.uniq-field
                    ,INPUT tt-dis-rule.value-type
                    ,INPUT tt-dis-rule.sts
                    ,input f-level-1
                    ,input f-level-2
                    ,input integer( tg-has-global )
                    ,input integer( tg-has-host )
                    ,input integer( tg-has-object )
                    ,input table tt-drt-prop
                    ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
  message error-status:get-message(1) view-as alert-box .
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
END.
p-rec = v-rec.
END PROCEDURE.
